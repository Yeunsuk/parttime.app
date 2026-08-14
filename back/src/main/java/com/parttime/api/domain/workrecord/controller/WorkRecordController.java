package com.parttime.api.domain.workrecord.controller;

import com.parttime.api.domain.workrecord.dto.ClockInRequest;
import com.parttime.api.domain.workrecord.dto.WorkRecordResponse;
import com.parttime.api.domain.workrecord.dto.WorkStatusResponse;
import com.parttime.api.domain.workrecord.service.WorkRecordService;
import com.parttime.api.global.response.ApiResponse;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/work-records")
@RequiredArgsConstructor
public class WorkRecordController {

    private final WorkRecordService workRecordService;

    // 현재 출근 상태
    @GetMapping("/status")
    public ApiResponse<WorkStatusResponse> getStatus(Authentication auth) {
        Long userId = (Long) auth.getPrincipal();
        return ApiResponse.ok(workRecordService.getStatus(userId));
    }

    // 출근
    @PostMapping("/clock-in")
    public ApiResponse<WorkRecordResponse> clockIn(
            Authentication auth,
            @RequestBody @Valid ClockInRequest req) {
        Long userId = (Long) auth.getPrincipal();
        return ApiResponse.ok(workRecordService.clockIn(userId, req));
    }

    // 퇴근
    @PatchMapping("/{id}/clock-out")
    public ApiResponse<WorkRecordResponse> clockOut(
            Authentication auth,
            @PathVariable Long id) {
        Long userId = (Long) auth.getPrincipal();
        return ApiResponse.ok(workRecordService.clockOut(userId, id));
    }

    // 달력 데이터
    @GetMapping("/calendar")
    public ApiResponse<List<WorkRecordResponse>> getCalendar(
            Authentication auth,
            @RequestParam int year,
            @RequestParam int month) {
        Long userId = (Long) auth.getPrincipal();
        return ApiResponse.ok(workRecordService.getCalendar(userId, year, month));
    }
}
