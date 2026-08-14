package com.parttime.api.domain.account.dto;

import com.parttime.api.entity.AccountQr;
import lombok.Getter;

@Getter
public class AccountQrResponse {
    private final Long id;
    private final String name;
    private final String qrImage;

    public AccountQrResponse(AccountQr qr) {
        this.id = qr.getId();
        this.name = qr.getName();
        this.qrImage = qr.getQrImage();
    }
}
