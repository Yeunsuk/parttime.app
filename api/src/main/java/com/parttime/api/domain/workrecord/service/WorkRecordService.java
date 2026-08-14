package com.parttime.api.domain.workrecord.service;

import com.parttime.api.domain.auth.repository.UserRepository;
import com.parttime.api.domain.worklog.repository.WorkLogRepository;
import com.parttime.api.domain.worklog.service.WorkLogService;
import com.parttime.api.domain.workrecord.dto.ClockInRequest;
import com.parttime.api.domain.workrecord.dto.WorkRecordResponse;
import com.parttime.api.domain.workrecord.dto.WorkStatusResponse;
import com.parttime.api.domain.workrecord.repository.WorkRecordRepository;
import com.parttime.api.domain.workplace.repository.WorkplaceMemberRepository;
import com.parttime.api.domain.workplace.repository.WorkplaceRepository;
import com.parttime.api.entity.PaymentType;
import com.parttime.api.entity.User;
import com.parttime.api.entity.WorkLog;
import com.parttime.api.entity.WorkRecord;
import com.parttime.api.entity.Workplace;
import com.parttime.api.global.exception.BusinessException;
import com.parttime.api.global.exception.ErrorCode;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.YearMonth;
import java.time.format.DateTimeFormatter;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.Set;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class WorkRecordService {

    private static final DateTimeFormatter LOG_TIME_FMT = DateTimeFormatter.ofPattern("HH:mm");

    private final WorkRecordRepository workRecordRepository;
    private final WorkplaceRepository workplaceRepository;
    private final WorkplaceMemberRepository workplaceMemberRepository;
    private final UserRepository userRepository;
    private final WorkLogService workLogService;
    private final WorkLogRepository workLogRepository;

    // 현재 출근 상태 조회
    @Transactional(readOnly = true)
    public WorkStatusResponse getStatus(Long workerId) {
        Optional<WorkRecord> current =
            workRecordRepository.findByWorkerIdAndClockOutIsNull(workerId);

        if (current.isPresent()) {
            return new WorkStatusResponse(true, new WorkRecordResponse(current.get()));
        }
        return new WorkStatusResponse(false, null);
    }

    // 출근
    @Transactional
    public WorkRecordResponse clockIn(Long workerId, ClockInRequest req) {
        // 이미 출근 중인지 확인
        workRecordRepository.findByWorkerIdAndClockOutIsNull(workerId)
            .ifPresent(r -> { throw new BusinessException(ErrorCode.ALREADY_CLOCKED_IN); });

        // 근무지 존재 + 멤버 확인
        Workplace workplace = workplaceRepository.findById(req.getWorkplaceId())
            .orElseThrow(() -> new BusinessException(ErrorCode.WORKPLACE_NOT_FOUND));

        if (!workplaceMemberRepository.existsByWorkplaceIdAndWorkerId(
                workplace.getId(), workerId)) {
            throw new BusinessException(ErrorCode.ACCESS_DENIED);
        }

        User worker = userRepository.findById(workerId)
            .orElseThrow(() -> new BusinessException(ErrorCode.USER_NOT_FOUND));

        // 근로자 본인이 직접 출퇴근을 찍는 경우는 항상 실제 시간을 재는 방식이므로,
        // 그 직원의 정산방식 설정과 무관하게 항상 TIME으로 남긴다.
        WorkRecord record = WorkRecord.builder()
            .workplace(workplace)
            .worker(worker)
            .clockIn(roundToHalfHour(LocalDateTime.now()))
            .paymentType(PaymentType.TIME)
            .build();

        workRecordRepository.save(record);

        workLogService.log(workplace, worker, worker, record.getId(),
            record.getClockIn().toLocalDate(), WorkLog.Action.CLOCK_IN,
            "출근 (" + record.getClockIn().format(LOG_TIME_FMT) + ")");

        return new WorkRecordResponse(record);
    }

    // 퇴근
    @Transactional
    public WorkRecordResponse clockOut(Long workerId, Long recordId) {
        WorkRecord record = workRecordRepository.findById(recordId)
            .orElseThrow(() -> new BusinessException(ErrorCode.RECORD_NOT_FOUND));

        // 본인 기록인지 확인
        if (!record.getWorker().getId().equals(workerId)) {
            throw new BusinessException(ErrorCode.ACCESS_DENIED);
        }

        if (record.getClockOut() != null) {
            throw new BusinessException(ErrorCode.NOT_CLOCKED_IN);
        }

        Workplace workplace = record.getWorkplace();
        User worker = record.getWorker();
        int hourlyWage = workplace.getHourlyWage();
        record.clockOut(roundToHalfHour(LocalDateTime.now()), hourlyWage);

        String message = "퇴근 (" + record.getClockOut().format(LOG_TIME_FMT) + ", "
            + record.getWorkMinutes() + "분)";

        // 30분 반올림 결과 근무시간이 0이 되는 경우(출퇴근을 30분 이내에 눌러 같은
        // 반시간대로 반올림됨) 근무기록으로 남기지 않는다. 로그는 남긴다 — 짧게
        // 찍고 나간 이력 자체가 사장 입장에서 확인할 가치가 있다.
        if (record.getWorkMinutes() != null && record.getWorkMinutes() <= 0) {
            workLogService.log(workplace, worker, worker, record.getId(),
                record.getClockIn().toLocalDate(), WorkLog.Action.CLOCK_OUT,
                message + " — 30분 미만이라 기록되지 않음");
            workRecordRepository.delete(record);
            return new WorkRecordResponse(record);
        }

        workLogService.log(workplace, worker, worker, record.getId(),
            record.getClockIn().toLocalDate(), WorkLog.Action.CLOCK_OUT, message);

        return new WorkRecordResponse(record);
    }

    // 0~14분은 버리고 15~29분은 올려서 :00, 30~44분은 버리고 45~59분은 올려서 :30/다음시 :00으로 맞춘다.
    // 예: 9:59 -> 10:00, 10:10 -> 10:00, 15:44 -> 15:30
    private LocalDateTime roundToHalfHour(LocalDateTime time) {
        int totalMinutes = time.getHour() * 60 + time.getMinute();
        int rounded = ((totalMinutes + 15) / 30) * 30;
        return time.toLocalDate().atStartOfDay().plusMinutes(rounded);
    }

    // 달력 데이터 (월별). "개인 근무내역"에서 시간 옆에 짧게 남기는 상태 표시
    // (생성됨/수정됨/삭제됨)를 위해 WorkLog를 함께 조회해 붙인다.
    @Transactional(readOnly = true)
    public List<WorkRecordResponse> getCalendar(Long workerId, int year, int month) {
        YearMonth ym = YearMonth.of(year, month);
        LocalDateTime start = ym.atDay(1).atStartOfDay();
        LocalDateTime end = ym.atEndOfMonth().atTime(23, 59, 59);

        List<WorkRecord> records = workRecordRepository
            .findByWorkerIdAndClockInBetween(workerId, start, end);

        List<Long> recordIds = records.stream().map(WorkRecord::getId).toList();
        Map<Long, WorkLog.Action> statusByRecordId = recordIds.isEmpty()
            ? Map.of()
            : workLogRepository
                .findByWorkerIdAndWorkRecordIdInAndActionIn(workerId, recordIds,
                    List.of(WorkLog.Action.RECORD_ADDED, WorkLog.Action.RECORD_MODIFIED))
                .stream()
                .collect(Collectors.toMap(
                    WorkLog::getWorkRecordId,
                    WorkLog::getAction,
                    // 같은 기록에 추가/수정 로그가 둘 다 있으면 "생성됨"을 우선한다.
                    (a, b) -> a == WorkLog.Action.RECORD_ADDED || b == WorkLog.Action.RECORD_ADDED
                        ? WorkLog.Action.RECORD_ADDED : WorkLog.Action.RECORD_MODIFIED));

        Set<LocalDate> deletedDates = workLogRepository
            .findByWorkerIdAndActionAndRecordDateBetween(
                workerId, WorkLog.Action.RECORD_DELETED, ym.atDay(1), ym.atEndOfMonth())
            .stream()
            .map(WorkLog::getRecordDate)
            .collect(Collectors.toSet());

        return records.stream()
            .map(r -> {
                WorkLog.Action status = statusByRecordId.get(r.getId());
                // 프론트는 "CREATED"/"MODIFIED"를 기대하므로 WorkLog.Action의 원래
                // 이름(RECORD_ADDED/RECORD_MODIFIED)을 그대로 보내면 안 된다.
                String creationStatus = status == null
                    ? null
                    : (status == WorkLog.Action.RECORD_ADDED ? "CREATED" : "MODIFIED");
                boolean deletedSameDay = deletedDates.contains(r.getClockIn().toLocalDate());
                return new WorkRecordResponse(r, creationStatus, deletedSameDay);
            })
            .toList();
    }
}
