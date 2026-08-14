package com.parttime.api.domain.payroll.dto;

import lombok.Getter;

// 근무지 소속 직원별 정산 요약 (각자의 정산기간 설정 기준)
@Getter
public class SettlementResponse {
    private final Long workerId;
    private final String workerName;
    private final String periodStart; // yyyy-MM-dd
    private final String periodEnd;   // yyyy-MM-dd
    private final double recordCount;
    private final int totalMinutes;
    private final int totalWage;
    private final String paymentType;

    public SettlementResponse(Long workerId, String workerName, String periodStart, String periodEnd,
                               double recordCount, int totalMinutes, int totalWage, String paymentType) {
        this.workerId = workerId;
        this.workerName = workerName;
        this.periodStart = periodStart;
        this.periodEnd = periodEnd;
        this.recordCount = recordCount;
        this.totalMinutes = totalMinutes;
        this.totalWage = totalWage;
        this.paymentType = paymentType;
    }
}
