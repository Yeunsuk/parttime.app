package com.parttime.api.domain.workplace.dto;

import com.parttime.api.entity.WorkplaceMember;
import lombok.Getter;

import java.util.Set;

@Getter
public class WorkerResponse {
    private final Long id;
    private final String name;
    private final Integer defaultClockInHour;
    private final Integer defaultClockInMinute;
    private final Integer defaultClockOutHour;
    private final Integer defaultClockOutMinute;
    private final Integer payPeriodStartDay;
    private final String paymentType;
    private final boolean workingDaysEnabled;
    private final Set<Integer> workingDays;

    public WorkerResponse(WorkplaceMember member) {
        this.id = member.getWorker().getId();
        this.name = member.getWorker().getName();
        this.defaultClockInHour = member.getDefaultClockInHour();
        this.defaultClockInMinute = member.getDefaultClockInMinute();
        this.defaultClockOutHour = member.getDefaultClockOutHour();
        this.defaultClockOutMinute = member.getDefaultClockOutMinute();
        this.payPeriodStartDay = member.getPayPeriodStartDay();
        this.paymentType = member.getPaymentTypeOrDefault().name();
        this.workingDaysEnabled = member.getWorkingDaysEnabledOrDefault();
        this.workingDays = member.getWorkingDays();
    }
}
