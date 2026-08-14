package com.parttime.api.domain.auth.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import lombok.Getter;

@Getter
public class SignupRequest {

    // 실제 이메일 발송(인증/재설정) 기능이 없어 이메일 형식을 강제하지 않는다 — 로그인 ID로만 쓰인다.
    @NotBlank
    private String email;

    @NotBlank
    @Size(min = 6)
    private String password;

    @NotBlank
    private String name;

    @NotBlank
    private String role; // OWNER | WORKER

    // role이 OWNER일 때만 필수 (WORKER는 무시됨)
    private String ownerAuthCode;
}
