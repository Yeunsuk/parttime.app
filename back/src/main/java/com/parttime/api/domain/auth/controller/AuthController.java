package com.parttime.api.domain.auth.controller;

import com.parttime.api.domain.auth.dto.AuthResponse;
import com.parttime.api.domain.auth.dto.LoginRequest;
import com.parttime.api.domain.auth.dto.RefreshTokenRequest;
import com.parttime.api.domain.auth.dto.SignupRequest;
import com.parttime.api.domain.auth.dto.UserResponse;
import com.parttime.api.domain.auth.service.AuthService;
import com.parttime.api.global.exception.BusinessException;
import com.parttime.api.global.exception.ErrorCode;
import com.parttime.api.global.response.ApiResponse;
import com.parttime.api.global.security.ClientIpResolver;
import com.parttime.api.global.security.LoginAttemptService;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/auth")
@RequiredArgsConstructor
public class AuthController {

    private final AuthService authService;
    private final LoginAttemptService loginAttemptService;
    private final ClientIpResolver clientIpResolver;

    @PostMapping("/signup")
    public ApiResponse<AuthResponse> signup(@RequestBody @Valid SignupRequest req) {
        return ApiResponse.ok(authService.signup(req));
    }

    // 브루트포스 방어(LoginRateLimitFilter)의 실제 차단 여부는 이미 필터에서 걸러졌으므로,
    // 여기서는 이 시도의 성공/실패만 LoginAttemptService에 기록하면 된다 — 실패 시 카운트,
    // 성공 시 그 IP의 카운트를 초기화한다.
    @PostMapping("/login")
    public ApiResponse<AuthResponse> login(HttpServletRequest request, @RequestBody @Valid LoginRequest req) {
        String clientIp = clientIpResolver.resolve(request);
        try {
            AuthResponse response = authService.login(req);
            loginAttemptService.recordSuccess(clientIp);
            return ApiResponse.ok(response);
        } catch (BusinessException e) {
            if (e.getErrorCode() == ErrorCode.INVALID_CREDENTIALS) {
                loginAttemptService.recordFailure(clientIp);
            }
            throw e;
        }
    }

    @PostMapping("/refresh")
    public ApiResponse<AuthResponse> refresh(@RequestBody @Valid RefreshTokenRequest req) {
        return ApiResponse.ok(authService.refresh(req.getRefreshToken()));
    }

    @GetMapping("/me")
    public ApiResponse<UserResponse> me(Authentication auth) {
        Long userId = (Long) auth.getPrincipal();
        return ApiResponse.ok(authService.getMe(userId));
    }
}
