package com.parttime.api.domain.workplace.controller;

import com.parttime.api.domain.workplace.dto.AddMemberRequest;
import com.parttime.api.domain.workplace.dto.CreateWorkplaceRequest;
import com.parttime.api.domain.workplace.dto.JoinWorkplaceRequest;
import com.parttime.api.domain.workplace.dto.UpdateDefaultTimeRequest;
import com.parttime.api.domain.workplace.dto.UpdateDisabledHoursRequest;
import com.parttime.api.domain.workplace.dto.UpdateEnabledMinutesRequest;
import com.parttime.api.domain.workplace.dto.UpdateMemberLimitRequest;
import com.parttime.api.domain.workplace.dto.UpdatePayPeriodRequest;
import com.parttime.api.domain.workplace.dto.UpdatePaymentTypeRequest;
import com.parttime.api.domain.workplace.dto.UpdateWorkingDaysRequest;
import com.parttime.api.domain.workplace.dto.WorkerResponse;
import com.parttime.api.domain.workplace.dto.WorkplaceResponse;
import com.parttime.api.domain.workplace.service.WorkplaceService;
import com.parttime.api.global.response.ApiResponse;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/workplaces")
@RequiredArgsConstructor
public class WorkplaceController {

    private final WorkplaceService workplaceService;

    // 근무지 생성 (사장)
    @PostMapping
    public ApiResponse<WorkplaceResponse> create(
            Authentication auth,
            @RequestBody @Valid CreateWorkplaceRequest req) {
        Long userId = (Long) auth.getPrincipal();
        return ApiResponse.ok(workplaceService.create(userId, req));
    }

    // 초대코드로 참가 (알바생)
    @PostMapping("/join")
    public ApiResponse<WorkplaceResponse> join(
            Authentication auth,
            @RequestBody @Valid JoinWorkplaceRequest req) {
        Long userId = (Long) auth.getPrincipal();
        return ApiResponse.ok(workplaceService.join(userId, req));
    }

    // 내 근무지 목록
    @GetMapping("/my")
    public ApiResponse<List<WorkplaceResponse>> getMyWorkplaces(Authentication auth) {
        Long userId = (Long) auth.getPrincipal();
        String role = auth.getAuthorities().iterator().next()
            .getAuthority().replace("ROLE_", "");
        return ApiResponse.ok(workplaceService.getMyWorkplaces(userId, role));
    }

    // 근무지 소속 근로자 목록 (사장 전용)
    @GetMapping("/{workplaceId}/workers")
    public ApiResponse<List<WorkerResponse>> getWorkers(
            Authentication auth,
            @PathVariable Long workplaceId) {
        Long ownerId = (Long) auth.getPrincipal();
        return ApiResponse.ok(workplaceService.getWorkers(ownerId, workplaceId));
    }

    // 근무지 인원제한 변경 (사장 전용)
    @PatchMapping("/{workplaceId}/member-limit")
    public ApiResponse<WorkplaceResponse> updateMemberLimit(
            Authentication auth,
            @PathVariable Long workplaceId,
            @RequestBody @Valid UpdateMemberLimitRequest req) {
        Long ownerId = (Long) auth.getPrincipal();
        return ApiResponse.ok(workplaceService.updateMemberLimit(ownerId, workplaceId, req));
    }

    // 근무지 시간설정 변경 (사장 전용): 여기서 선택된 시(0~23)는 근무기록 생성/수정 시간
    // 목록에서 제외된다
    @PatchMapping("/{workplaceId}/disabled-hours")
    public ApiResponse<WorkplaceResponse> updateDisabledHours(
            Authentication auth,
            @PathVariable Long workplaceId,
            @RequestBody @Valid UpdateDisabledHoursRequest req) {
        Long ownerId = (Long) auth.getPrincipal();
        return ApiResponse.ok(workplaceService.updateDisabledHours(ownerId, workplaceId, req));
    }

    // 근무지 분설정 변경 (사장 전용): 여기서 선택된 분(0~59)만 근무기록 생성/수정 시간
    // 목록에 표시된다 (기본값 0, 30분)
    @PatchMapping("/{workplaceId}/enabled-minutes")
    public ApiResponse<WorkplaceResponse> updateEnabledMinutes(
            Authentication auth,
            @PathVariable Long workplaceId,
            @RequestBody @Valid UpdateEnabledMinutesRequest req) {
        Long ownerId = (Long) auth.getPrincipal();
        return ApiResponse.ok(workplaceService.updateEnabledMinutes(ownerId, workplaceId, req));
    }

    // 직원 추가 (사장 전용): 아이디가 이미 있으면 그 계정을, 없으면 기본 비밀번호로 새 계정을 만들어 추가
    @PostMapping("/{workplaceId}/members")
    public ApiResponse<WorkerResponse> addMember(
            Authentication auth,
            @PathVariable Long workplaceId,
            @RequestBody @Valid AddMemberRequest req) {
        Long ownerId = (Long) auth.getPrincipal();
        return ApiResponse.ok(workplaceService.addMember(ownerId, workplaceId, req));
    }

    // 직원 퇴장 (사장 전용): 근무기록은 그대로 두고 소속만 해제
    @DeleteMapping("/{workplaceId}/members/{workerId}")
    public ApiResponse<Void> removeMember(
            Authentication auth,
            @PathVariable Long workplaceId,
            @PathVariable Long workerId) {
        Long ownerId = (Long) auth.getPrincipal();
        workplaceService.removeMember(ownerId, workplaceId, workerId);
        return ApiResponse.ok(null);
    }

    // 직원별 기본 근무시간 설정 (사장 전용)
    @PatchMapping("/{workplaceId}/members/{workerId}/default-time")
    public ApiResponse<WorkerResponse> updateDefaultTime(
            Authentication auth,
            @PathVariable Long workplaceId,
            @PathVariable Long workerId,
            @RequestBody @Valid UpdateDefaultTimeRequest req) {
        Long ownerId = (Long) auth.getPrincipal();
        return ApiResponse.ok(
            workplaceService.updateDefaultTime(ownerId, workplaceId, workerId, req));
    }

    // 직원별 정산 기간 설정 (사장 전용)
    @PatchMapping("/{workplaceId}/members/{workerId}/pay-period")
    public ApiResponse<WorkerResponse> updatePayPeriod(
            Authentication auth,
            @PathVariable Long workplaceId,
            @PathVariable Long workerId,
            @RequestBody @Valid UpdatePayPeriodRequest req) {
        Long ownerId = (Long) auth.getPrincipal();
        return ApiResponse.ok(
            workplaceService.updatePayPeriod(ownerId, workplaceId, workerId, req));
    }

    // 직원별 정산 방식 설정 (사장 전용)
    @PatchMapping("/{workplaceId}/members/{workerId}/payment-type")
    public ApiResponse<WorkerResponse> updatePaymentType(
            Authentication auth,
            @PathVariable Long workplaceId,
            @PathVariable Long workerId,
            @RequestBody @Valid UpdatePaymentTypeRequest req) {
        Long ownerId = (Long) auth.getPrincipal();
        return ApiResponse.ok(
            workplaceService.updatePaymentType(ownerId, workplaceId, workerId, req));
    }

    // 직원별 요일설정 (사장 전용)
    @PatchMapping("/{workplaceId}/members/{workerId}/working-days")
    public ApiResponse<WorkerResponse> updateWorkingDays(
            Authentication auth,
            @PathVariable Long workplaceId,
            @PathVariable Long workerId,
            @RequestBody @Valid UpdateWorkingDaysRequest req) {
        Long ownerId = (Long) auth.getPrincipal();
        return ApiResponse.ok(
            workplaceService.updateWorkingDays(ownerId, workplaceId, workerId, req));
    }
}
