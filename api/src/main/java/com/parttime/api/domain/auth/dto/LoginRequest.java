package com.parttime.api.domain.auth.dto;

import jakarta.validation.constraints.NotBlank;
import lombok.Getter;

@Getter
public class LoginRequest {

    // 실제 이메일 발송(인증/재설정) 기능이 없어 이메일 형식을 강제하지 않는다 — 로그인 ID로만 쓰인다.
    @NotBlank
    private String email;

    @NotBlank
    private String password;
}
