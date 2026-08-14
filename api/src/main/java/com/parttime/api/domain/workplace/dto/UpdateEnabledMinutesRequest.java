package com.parttime.api.domain.workplace.dto;

import jakarta.validation.constraints.NotNull;
import lombok.Getter;

import java.util.Set;

@Getter
public class UpdateEnabledMinutesRequest {

    @NotNull
    private Set<Integer> enabledMinutes;
}
