package com.parttime.api.domain.workplace.dto;

import jakarta.validation.constraints.NotBlank;
import lombok.Getter;

@Getter
public class JoinWorkplaceRequest {

    @NotBlank
    private String inviteCode;
}
