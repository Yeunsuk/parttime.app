package com.parttime.api.domain.account.dto;

import com.parttime.api.entity.Account;
import com.parttime.api.entity.AccountQr;
import lombok.Getter;

import java.util.List;

@Getter
public class AccountResponse {
    private final Long id;
    private final String accountName;
    private final String accountNumber;
    private final String bankName;
    private final List<AccountQrResponse> qrCodes;

    public AccountResponse(Account account, List<AccountQr> qrCodes) {
        this.id = account.getId();
        this.accountName = account.getAccountName();
        this.accountNumber = account.getAccountNumber();
        this.bankName = account.getBankName();
        this.qrCodes = qrCodes.stream().map(AccountQrResponse::new).toList();
    }
}
