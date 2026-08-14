package com.parttime.api.domain.workplace.dto;

import jakarta.validation.constraints.NotNull;
import lombok.Getter;

import java.util.Set;

@Getter
public class UpdateWorkingDaysRequest {

    @NotNull
    private Boolean enabled;

    // enabled=false("미설정")면 무시되고 빈 집합으로 저장된다. 1=월요일 ... 7=일요일.
    private Set<Integer> days;
}
