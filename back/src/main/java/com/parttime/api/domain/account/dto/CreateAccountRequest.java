package com.parttime.api.domain.account.dto;

import jakarta.validation.constraints.NotBlank;
import lombok.Getter;

@Getter
public class CreateAccountRequest {

    @NotBlank
    private String accountName;

    @NotBlank
    private String accountNumber;

    @NotBlank
    private String bankName;
}
