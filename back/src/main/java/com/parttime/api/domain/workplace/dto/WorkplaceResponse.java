package com.parttime.api.domain.workplace.dto;

import com.parttime.api.entity.Workplace;
import lombok.Getter;

import java.util.Set;

@Getter
public class WorkplaceResponse {
    private final Long id;
    private final String name;
    private final String inviteCode;
    private final Integer hourlyWage;
    private final String ownerName;
    private final Integer memberLimit;
    private final Set<Integer> disabledHours;
    private final Set<Integer> enabledMinutes;

    public WorkplaceResponse(Workplace w) {
        this.id = w.getId();
        this.name = w.getName();
        this.inviteCode = w.getInviteCode();
        this.hourlyWage = w.getHourlyWage();
        this.ownerName = w.getOwner().getName();
        this.memberLimit = w.getMemberLimitOrDefault();
        this.disabledHours = w.getDisabledHours();
        this.enabledMinutes = w.getEnabledMinutesOrDefault();
    }
}
