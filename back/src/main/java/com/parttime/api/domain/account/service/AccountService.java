package com.parttime.api.domain.account.service;

import com.parttime.api.domain.account.dto.AccountResponse;
import com.parttime.api.domain.account.dto.AddAccountQrRequest;
import com.parttime.api.domain.account.dto.CreateAccountRequest;
import com.parttime.api.domain.account.repository.AccountQrRepository;
import com.parttime.api.domain.account.repository.AccountRepository;
import com.parttime.api.domain.workplace.repository.WorkplaceRepository;
import com.parttime.api.entity.Account;
import com.parttime.api.entity.AccountQr;
import com.parttime.api.entity.Workplace;
import com.parttime.api.global.exception.BusinessException;
import com.parttime.api.global.exception.ErrorCode;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
@RequiredArgsConstructor
public class AccountService {

    private final AccountRepository accountRepository;
    private final AccountQrRepository accountQrRepository;
    private final WorkplaceRepository workplaceRepository;

    // 근무지 계좌 추가 (사장 전용)
    @Transactional
    public AccountResponse create(Long ownerId, Long workplaceId, CreateAccountRequest req) {
        Workplace workplace = getOwnedWorkplace(ownerId, workplaceId);

        Account account = Account.builder()
            .workplace(workplace)
            .accountName(req.getAccountName())
            .accountNumber(req.getAccountNumber())
            .bankName(req.getBankName())
            .build();
        accountRepository.save(account);

        return new AccountResponse(account, List.of());
    }

    // 근무지 계좌 목록 (사장 전용)
    @Transactional(readOnly = true)
    public List<AccountResponse> getAccounts(Long ownerId, Long workplaceId) {
        getOwnedWorkplace(ownerId, workplaceId);

        return accountRepository.findByWorkplaceIdOrderByIdAsc(workplaceId).stream()
            .map(account -> new AccountResponse(account,
                accountQrRepository.findByAccountIdOrderByIdAsc(account.getId())))
            .toList();
    }

    // 계좌에 QR 추가 (사장 전용). 은행/간편결제 앱마다 QR 규격이 달라 여러 개를
    // 이름으로 구분해 등록할 수 있다.
    @Transactional
    public AccountResponse addQr(
            Long ownerId, Long workplaceId, Long accountId, AddAccountQrRequest req) {
        getOwnedWorkplace(ownerId, workplaceId);

        Account account = accountRepository.findById(accountId)
            .orElseThrow(() -> new BusinessException(ErrorCode.ACCOUNT_NOT_FOUND));

        AccountQr qr = AccountQr.builder()
            .account(account)
            .name(req.getName())
            .qrImage(req.getQrImage())
            .build();
        accountQrRepository.save(qr);

        return new AccountResponse(account, accountQrRepository.findByAccountIdOrderByIdAsc(accountId));
    }

    // 계좌 QR 삭제 (사장 전용)
    @Transactional
    public AccountResponse deleteQr(Long ownerId, Long workplaceId, Long accountId, Long qrId) {
        getOwnedWorkplace(ownerId, workplaceId);

        Account account = accountRepository.findById(accountId)
            .orElseThrow(() -> new BusinessException(ErrorCode.ACCOUNT_NOT_FOUND));
        AccountQr qr = accountQrRepository.findByIdAndAccountId(qrId, accountId)
            .orElseThrow(() -> new BusinessException(ErrorCode.ACCOUNT_QR_NOT_FOUND));

        accountQrRepository.delete(qr);
        return new AccountResponse(account, accountQrRepository.findByAccountIdOrderByIdAsc(accountId));
    }

    // 계좌 삭제 (사장 전용)
    @Transactional
    public void delete(Long ownerId, Long workplaceId, Long accountId) {
        getOwnedWorkplace(ownerId, workplaceId);

        Account account = accountRepository.findById(accountId)
            .orElseThrow(() -> new BusinessException(ErrorCode.ACCOUNT_NOT_FOUND));

        // FK 제약 위반 없이 삭제되도록 연결된 QR들을 먼저 지운다.
        accountQrRepository.deleteByAccountId(accountId);
        accountRepository.delete(account);
    }

    private Workplace getOwnedWorkplace(Long ownerId, Long workplaceId) {
        Workplace workplace = workplaceRepository.findById(workplaceId)
            .orElseThrow(() -> new BusinessException(ErrorCode.WORKPLACE_NOT_FOUND));

        if (!workplace.getOwner().getId().equals(ownerId)) {
            throw new BusinessException(ErrorCode.ACCESS_DENIED);
        }
        return workplace;
    }
}
