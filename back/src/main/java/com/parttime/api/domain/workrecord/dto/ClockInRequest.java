package com.parttime.api.domain.workrecord.dto;

import jakarta.validation.constraints.NotNull;
import lombok.Getter;

@Getter
public class ClockInRequest {

    @NotNull
    private Long workplaceId;
}
