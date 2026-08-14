package com.parttime.api.domain.workplace.service;

import com.parttime.api.domain.auth.repository.UserRepository;
import com.parttime.api.domain.workplace.dto.AddMemberRequest;
import com.parttime.api.domain.workplace.dto.CreateWorkplaceRequest;
import com.parttime.api.domain.workplace.dto.JoinWorkplaceRequest;
import com.parttime.api.domain.workplace.dto.UpdateDefaultTimeRequest;
import com.parttime.api.domain.workplace.dto.UpdateDisabledHoursRequest;
import com.parttime.api.domain.workplace.dto.UpdateEnabledMinutesRequest;
import com.parttime.api.domain.workplace.dto.UpdatePayPeriodRequest;
import com.parttime.api.domain.workplace.dto.UpdatePaymentTypeRequest;
import com.parttime.api.domain.workplace.dto.UpdateWorkingDaysRequest;
import com.parttime.api.domain.workplace.dto.WorkerResponse;
import com.parttime.api.domain.workplace.dto.WorkplaceResponse;
import com.parttime.api.domain.workplace.dto.UpdateMemberLimitRequest;
import com.parttime.api.domain.workplace.repository.WorkplaceMemberRepository;
import com.parttime.api.domain.workplace.repository.WorkplaceRepository;
import com.parttime.api.entity.PaymentType;
import com.parttime.api.entity.User;
import com.parttime.api.entity.Workplace;
import com.parttime.api.entity.WorkplaceMember;
import com.parttime.api.global.exception.BusinessException;
import com.parttime.api.global.exception.ErrorCode;
import lombok.RequiredArgsConstructor;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.Comparator;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Service
@RequiredArgsConstructor
public class WorkplaceService {

    private final WorkplaceRepository workplaceRepository;
    private final WorkplaceMemberRepository workplaceMemberRepository;
    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;

    // 사장이 직접 추가한 직원 계정이 새로 생성될 때 부여하는 기본 비밀번호 (본인이 나중에 로그인해서 바꿀 수 있음)
    private static final String DEFAULT_NEW_MEMBER_PASSWORD = "1234";

    // 근무지 생성 (사장)
    @Transactional
    public WorkplaceResponse create(Long ownerId, CreateWorkplaceRequest req) {
        User owner = userRepository.findById(ownerId)
            .orElseThrow(() -> new BusinessException(ErrorCode.USER_NOT_FOUND));

        String inviteCode = generateUniqueCode();

        Workplace workplace = Workplace.builder()
            .owner(owner)
            .name(req.getName())
            .inviteCode(inviteCode)
            .hourlyWage(req.getHourlyWage())
            .build();

        workplaceRepository.save(workplace);
        return new WorkplaceResponse(workplace);
    }

    // 초대코드로 참가 (알바생)
    @Transactional
    public WorkplaceResponse join(Long workerId, JoinWorkplaceRequest req) {
        Workplace workplace = workplaceRepository.findByInviteCode(req.getInviteCode())
            .orElseThrow(() -> new BusinessException(ErrorCode.INVALID_INVITE_CODE));

        User worker = userRepository.findById(workerId)
            .orElseThrow(() -> new BusinessException(ErrorCode.USER_NOT_FOUND));

        if (workplaceMemberRepository.existsByWorkplaceIdAndWorkerId(
                workplace.getId(), workerId)) {
            return new WorkplaceResponse(workplace); // 이미 참가된 경우 그냥 반환
        }

        long currentCount = workplaceMemberRepository.countByWorkplaceId(workplace.getId());
        if (currentCount >= workplace.getMemberLimitOrDefault()) {
            throw new BusinessException(ErrorCode.WORKPLACE_MEMBER_LIMIT_EXCEEDED);
        }

        WorkplaceMember member = WorkplaceMember.builder()
            .workplace(workplace)
            .worker(worker)
            .build();

        workplaceMemberRepository.save(member);
        return new WorkplaceResponse(workplace);
    }

    // 내 근무지 목록 조회
    @Transactional(readOnly = true)
    public List<WorkplaceResponse> getMyWorkplaces(Long userId, String role) {
        if (role.equals("OWNER")) {
            // 사장: 내가 만든 근무지
            return workplaceRepository.findAll().stream()
                .filter(w -> w.getOwner().getId().equals(userId))
                .map(WorkplaceResponse::new)
                .toList();
        } else {
            // 알바생: 참가한 근무지
            return workplaceMemberRepository.findByWorkerId(userId).stream()
                .map(m -> new WorkplaceResponse(m.getWorkplace()))
                .toList();
        }
    }

    // 근무지 소속 근로자 목록 (사장 전용, 예: 근로자별 달력 색상 설정 화면에서 사용)
    // 이름순으로 가져온 뒤 정산방식(시간제 먼저) 기준으로 다시 정렬한다 —
    // sorted()는 안정 정렬이라 같은 정산방식 안에서는 기존 이름순이 그대로 유지된다.
    @Transactional(readOnly = true)
    public List<WorkerResponse> getWorkers(Long ownerId, Long workplaceId) {
        Workplace workplace = getOwnedWorkplace(ownerId, workplaceId);

        return workplaceMemberRepository.findByWorkplaceIdOrderByWorkerNameAsc(workplace.getId()).stream()
            .sorted(Comparator.comparingInt(
                m -> m.getPaymentTypeOrDefault() == PaymentType.COUNT ? 1 : 0))
            .map(WorkerResponse::new)
            .toList();
    }

    // 근무지 인원제한 변경 (사장 전용)
    @Transactional
    public WorkplaceResponse updateMemberLimit(
            Long ownerId, Long workplaceId, UpdateMemberLimitRequest req) {

        Workplace workplace = getOwnedWorkplace(ownerId, workplaceId);

        long currentCount = workplaceMemberRepository.countByWorkplaceId(workplace.getId());
        if (req.getMemberLimit() < currentCount) {
            throw new BusinessException(ErrorCode.MEMBER_LIMIT_BELOW_CURRENT_COUNT);
        }

        workplace.changeMemberLimit(req.getMemberLimit());
        return new WorkplaceResponse(workplace);
    }

    // 근무지 시간설정 변경 (사장 전용). 여기서 선택된 시(0~23)는 그 근무지의 모든 직원의
    // 근무기록 생성/수정 시간 목록에서 제외된다.
    @Transactional
    public WorkplaceResponse updateDisabledHours(
            Long ownerId, Long workplaceId, UpdateDisabledHoursRequest req) {

        Workplace workplace = getOwnedWorkplace(ownerId, workplaceId);
        workplace.changeDisabledHours(req.getDisabledHours());
        return new WorkplaceResponse(workplace);
    }

    // 근무지 분설정 변경 (사장 전용). 여기서 선택된 분(0~59)만 근무기록 생성/수정 시간
    // 목록에 표시된다 (기본값 0, 30분).
    @Transactional
    public WorkplaceResponse updateEnabledMinutes(
            Long ownerId, Long workplaceId, UpdateEnabledMinutesRequest req) {

        Workplace workplace = getOwnedWorkplace(ownerId, workplaceId);
        workplace.changeEnabledMinutes(req.getEnabledMinutes());
        return new WorkplaceResponse(workplace);
    }

    // 직원 추가 (사장 전용). 아이디가 이미 가입되어 있으면 그 계정을 추가하고,
    // 없으면 기본 비밀번호로 새 WORKER 계정을 만들어 추가한다.
    @Transactional
    public WorkerResponse addMember(Long ownerId, Long workplaceId, AddMemberRequest req) {
        Workplace workplace = getOwnedWorkplace(ownerId, workplaceId);

        User worker = userRepository.findByEmail(req.getEmail())
            .map(existing -> {
                if (existing.getRole() != User.Role.WORKER) {
                    throw new BusinessException(ErrorCode.CANNOT_ADD_OWNER_AS_WORKER);
                }
                return existing;
            })
            .orElseGet(() -> userRepository.save(User.builder()
                .email(req.getEmail())
                .password(passwordEncoder.encode(DEFAULT_NEW_MEMBER_PASSWORD))
                .name(req.getEmail())
                .role(User.Role.WORKER)
                .build()));

        Optional<WorkplaceMember> existing = workplaceMemberRepository
            .findByWorkplaceIdAndWorkerId(workplace.getId(), worker.getId());
        if (existing.isPresent()) {
            return new WorkerResponse(existing.get()); // 이미 소속된 경우 그냥 반환
        }

        long currentCount = workplaceMemberRepository.countByWorkplaceId(workplace.getId());
        if (currentCount >= workplace.getMemberLimitOrDefault()) {
            throw new BusinessException(ErrorCode.WORKPLACE_MEMBER_LIMIT_EXCEEDED);
        }

        WorkplaceMember member = WorkplaceMember.builder()
            .workplace(workplace)
            .worker(worker)
            .build();
        workplaceMemberRepository.save(member);

        return new WorkerResponse(member);
    }

    // 직원 퇴장 (사장 전용). 소속(WorkplaceMember)만 끊고, 그 직원의 기존 근무기록(WorkRecord)은 그대로 둔다.
    @Transactional
    public void removeMember(Long ownerId, Long workplaceId, Long workerId) {
        Workplace workplace = getOwnedWorkplace(ownerId, workplaceId);

        WorkplaceMember member = workplaceMemberRepository
            .findByWorkplaceIdAndWorkerId(workplace.getId(), workerId)
            .orElseThrow(() -> new BusinessException(ErrorCode.WORKPLACE_MEMBER_NOT_FOUND));

        workplaceMemberRepository.delete(member);
    }

    // 직원별 기본 근무시간 설정 (사장 전용). 근무기록 추가 다이얼로그를 열 때 이 값으로 미리 채워진다.
    @Transactional
    public WorkerResponse updateDefaultTime(
            Long ownerId, Long workplaceId, Long workerId, UpdateDefaultTimeRequest req) {
        getOwnedWorkplace(ownerId, workplaceId);

        WorkplaceMember member = workplaceMemberRepository
            .findByWorkplaceIdAndWorkerId(workplaceId, workerId)
            .orElseThrow(() -> new BusinessException(ErrorCode.WORKPLACE_MEMBER_NOT_FOUND));

        member.changeDefaultTime(
            req.getClockInHour(), req.getClockInMinute(),
            req.getClockOutHour(), req.getClockOutMinute());
        return new WorkerResponse(member);
    }

    // 직원별 정산 기간 시작일 설정 (사장 전용). 1이면 달력월(기본값)과 동일하다.
    @Transactional
    public WorkerResponse updatePayPeriod(
            Long ownerId, Long workplaceId, Long workerId, UpdatePayPeriodRequest req) {
        getOwnedWorkplace(ownerId, workplaceId);

        WorkplaceMember member = workplaceMemberRepository
            .findByWorkplaceIdAndWorkerId(workplaceId, workerId)
            .orElseThrow(() -> new BusinessException(ErrorCode.WORKPLACE_MEMBER_NOT_FOUND));

        member.changePayPeriodStartDay(req.getPayPeriodStartDay());
        return new WorkerResponse(member);
    }

    // 직원별 정산 방식 설정 (사장 전용). 기존 직원은 전부 미설정(null) 상태라 TIME으로 취급된다.
    @Transactional
    public WorkerResponse updatePaymentType(
            Long ownerId, Long workplaceId, Long workerId, UpdatePaymentTypeRequest req) {
        getOwnedWorkplace(ownerId, workplaceId);

        WorkplaceMember member = workplaceMemberRepository
            .findByWorkplaceIdAndWorkerId(workplaceId, workerId)
            .orElseThrow(() -> new BusinessException(ErrorCode.WORKPLACE_MEMBER_NOT_FOUND));

        member.changePaymentType(req.getPaymentType());
        return new WorkerResponse(member);
    }

    // 직원별 요일설정 (사장 전용). "미설정"이면 요일 제한 없이 항상 활성으로 취급한다 —
    // 근무기록 추가 다이얼로그에서 근로자 정렬 우선순위(오늘 요일에 활성인지)에 쓰인다.
    @Transactional
    public WorkerResponse updateWorkingDays(
            Long ownerId, Long workplaceId, Long workerId, UpdateWorkingDaysRequest req) {
        getOwnedWorkplace(ownerId, workplaceId);

        WorkplaceMember member = workplaceMemberRepository
            .findByWorkplaceIdAndWorkerId(workplaceId, workerId)
            .orElseThrow(() -> new BusinessException(ErrorCode.WORKPLACE_MEMBER_NOT_FOUND));

        member.changeWorkingDays(req.getEnabled(), req.getDays());
        return new WorkerResponse(member);
    }

    private Workplace getOwnedWorkplace(Long ownerId, Long workplaceId) {
        Workplace workplace = workplaceRepository.findById(workplaceId)
            .orElseThrow(() -> new BusinessException(ErrorCode.WORKPLACE_NOT_FOUND));

        if (!workplace.getOwner().getId().equals(ownerId)) {
            throw new BusinessException(ErrorCode.ACCESS_DENIED);
        }
        return workplace;
    }

    private String generateUniqueCode() {
        String code;
        do {
            code = UUID.randomUUID().toString().replace("-", "").substring(0, 6).toUpperCase();
        } while (workplaceRepository.existsByInviteCode(code));
        return code;
    }
}
