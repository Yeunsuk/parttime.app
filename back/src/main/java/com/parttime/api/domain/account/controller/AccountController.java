package com.parttime.api.domain.account.controller;

import com.parttime.api.domain.account.dto.AccountResponse;
import com.parttime.api.domain.account.dto.AddAccountQrRequest;
import com.parttime.api.domain.account.dto.CreateAccountRequest;
import com.parttime.api.domain.account.service.AccountService;
import com.parttime.api.global.response.ApiResponse;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/workplaces/{workplaceId}/accounts")
@RequiredArgsConstructor
public class AccountController {

    private final AccountService accountService;

    // 근무지 계좌 추가 (사장 전용)
    @PostMapping
    public ApiResponse<AccountResponse> create(
            Authentication auth,
            @PathVariable Long workplaceId,
            @RequestBody @Valid CreateAccountRequest req) {
        Long ownerId = (Long) auth.getPrincipal();
        return ApiResponse.ok(accountService.create(ownerId, workplaceId, req));
    }

    // 근무지 계좌 목록 (사장 전용)
    @GetMapping
    public ApiResponse<List<AccountResponse>> getAccounts(
            Authentication auth,
            @PathVariable Long workplaceId) {
        Long ownerId = (Long) auth.getPrincipal();
        return ApiResponse.ok(accountService.getAccounts(ownerId, workplaceId));
    }

    // 계좌에 QR 추가 (사장 전용): 은행/간편결제 앱마다 QR 규격이 달라 이름을 붙여 구분한다
    @PostMapping("/{accountId}/qrs")
    public ApiResponse<AccountResponse> addQr(
            Authentication auth,
            @PathVariable Long workplaceId,
            @PathVariable Long accountId,
            @RequestBody @Valid AddAccountQrRequest req) {
        Long ownerId = (Long) auth.getPrincipal();
        return ApiResponse.ok(accountService.addQr(ownerId, workplaceId, accountId, req));
    }

    // 계좌 QR 삭제 (사장 전용)
    @DeleteMapping("/{accountId}/qrs/{qrId}")
    public ApiResponse<AccountResponse> deleteQr(
            Authentication auth,
            @PathVariable Long workplaceId,
            @PathVariable Long accountId,
            @PathVariable Long qrId) {
        Long ownerId = (Long) auth.getPrincipal();
        return ApiResponse.ok(accountService.deleteQr(ownerId, workplaceId, accountId, qrId));
    }

    // 계좌 삭제 (사장 전용)
    @DeleteMapping("/{accountId}")
    public ApiResponse<Void> delete(
            Authentication auth,
            @PathVariable Long workplaceId,
            @PathVariable Long accountId) {
        Long ownerId = (Long) auth.getPrincipal();
        accountService.delete(ownerId, workplaceId, accountId);
        return ApiResponse.ok(null);
    }
}
