package com.parttime.api.domain.workplace.dto;

import jakarta.validation.constraints.NotNull;
import lombok.Getter;

import java.util.Set;

@Getter
public class UpdateDisabledHoursRequest {

    @NotNull
    private Set<Integer> disabledHours;
}
