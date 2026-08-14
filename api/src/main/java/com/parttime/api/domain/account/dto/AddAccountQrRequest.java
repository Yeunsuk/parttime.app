package com.parttime.api.domain.account.dto;

import jakarta.validation.constraints.NotBlank;
import lombok.Getter;

@Getter
public class AddAccountQrRequest {

    @NotBlank
    private String name;

    @NotBlank
    private String qrImage;
}
