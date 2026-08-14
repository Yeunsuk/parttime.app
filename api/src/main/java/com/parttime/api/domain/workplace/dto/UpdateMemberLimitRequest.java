package com.parttime.api.domain.workplace.dto;

import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotNull;
import lombok.Getter;

@Getter
public class UpdateMemberLimitRequest {

    @NotNull
    @Min(1)
    private Integer memberLimit;
}
