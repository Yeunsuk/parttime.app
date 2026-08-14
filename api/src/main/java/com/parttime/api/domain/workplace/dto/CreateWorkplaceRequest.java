package com.parttime.api.domain.workplace.dto;

import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.Getter;

@Getter
public class CreateWorkplaceRequest {

    @NotBlank
    private String name;

    @NotNull
    @Min(0)
    private Integer hourlyWage;
}
