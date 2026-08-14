package com.parttime.api.domain.payroll.dto;

import lombok.Getter;

@Getter
public class PayrollSummaryResponse {
    private final Long workerId;
    private final String workerName;
    private final int totalWage;
    private final int totalMinutes;
    private final int workDays;

    public PayrollSummaryResponse(Long workerId, String workerName,
                                   int totalWage, int totalMinutes, int workDays) {
        this.workerId = workerId;
        this.workerName = workerName;
        this.totalWage = totalWage;
        this.totalMinutes = totalMinutes;
        this.workDays = workDays;
    }
}
