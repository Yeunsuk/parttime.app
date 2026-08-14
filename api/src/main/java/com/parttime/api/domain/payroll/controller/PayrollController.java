package com.parttime.api.domain.payroll.controller;

import com.parttime.api.domain.payroll.dto.ModifyRecordRequest;
import com.parttime.api.domain.payroll.dto.PayrollDetailResponse;
import com.parttime.api.domain.payroll.dto.PayrollSummaryResponse;
import com.parttime.api.domain.payroll.dto.SettlementResponse;
import com.parttime.api.domain.payroll.service.PayrollService;
import com.parttime.api.global.response.ApiResponse;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequiredArgsConstructor
public class PayrollController {

    private final PayrollService payrollService;

    // 근무지 월별 정산 요약
    @GetMapping("/api/workplaces/{workplaceId}/payroll")
    public ApiResponse<List<PayrollSummaryResponse>> getPayrollSummary(
            Authentication auth,
            @PathVariable Long workplaceId,
            @RequestParam int year,
            @RequestParam int month) {
        Long ownerId = (Long) auth.getPrincipal();
        return ApiResponse.ok(
            payrollService.getPayrollSummary(ownerId, workplaceId, year, month));
    }

    // 근무지 전체 근로자 근무기록 (달력용)
    @GetMapping("/api/workplaces/{workplaceId}/records")
    public ApiResponse<List<PayrollDetailResponse>> getWorkplaceRecords(
            Authentication auth,
            @PathVariable Long workplaceId,
            @RequestParam int year,
            @RequestParam int month) {
        Long ownerId = (Long) auth.getPrincipal();
        return ApiResponse.ok(
            payrollService.getWorkplaceRecords(ownerId, workplaceId, year, month));
    }

    // 근로자 상세 근무기록
    @GetMapping("/api/workplaces/{workplaceId}/workers/{workerId}/records")
    public ApiResponse<List<PayrollDetailResponse>> getWorkerDetail(
            Authentication auth,
            @PathVariable Long workplaceId,
            @PathVariable Long workerId,
            @RequestParam int year,
            @RequestParam int month) {
        Long ownerId = (Long) auth.getPrincipal();
        return ApiResponse.ok(
            payrollService.getWorkerDetail(ownerId, workplaceId, workerId, year, month));
    }

    // 근무기록 수정
    @PatchMapping("/api/work-records/{recordId}/modify")
    public ApiResponse<PayrollDetailResponse> modifyRecord(
            Authentication auth,
            @PathVariable Long recordId,
            @RequestBody @Valid ModifyRecordRequest req) {
        Long ownerId = (Long) auth.getPrincipal();
        return ApiResponse.ok(payrollService.modifyRecord(ownerId, recordId, req));
    }

    // 근무기록 추가 (사장이 근로자 근무시간을 새로 등록)
    @PostMapping("/api/workplaces/{workplaceId}/workers/{workerId}/records")
    public ApiResponse<PayrollDetailResponse> addRecord(
            Authentication auth,
            @PathVariable Long workplaceId,
            @PathVariable Long workerId,
            @RequestBody @Valid ModifyRecordRequest req) {
        Long ownerId = (Long) auth.getPrincipal();
        return ApiResponse.ok(payrollService.addRecord(ownerId, workplaceId, workerId, req));
    }

    // 근무기록 삭제
    @DeleteMapping("/api/work-records/{recordId}")
    public ApiResponse<Void> deleteRecord(
            Authentication auth,
            @PathVariable Long recordId) {
        Long ownerId = (Long) auth.getPrincipal();
        payrollService.deleteRecord(ownerId, recordId);
        return ApiResponse.ok(null);
    }

    // 근무지 소속 직원별 정산 (각자 정산기간 설정 기준, 선택된 (year, month)가 속한 기간)
    @GetMapping("/api/workplaces/{workplaceId}/settlement")
    public ApiResponse<List<SettlementResponse>> getSettlement(
            Authentication auth,
            @PathVariable Long workplaceId,
            @RequestParam int year,
            @RequestParam int month) {
        Long ownerId = (Long) auth.getPrincipal();
        return ApiResponse.ok(payrollService.getSettlement(ownerId, workplaceId, year, month));
    }
}
