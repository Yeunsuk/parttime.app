package com.parttime.api.domain.workplace.dto;

import jakarta.validation.constraints.NotBlank;
import lombok.Getter;

@Getter
public class AddMemberRequest {

    // 로그인 ID. 이미 가입된 계정이면 그 계정을 추가하고, 없으면 기본 비밀번호로 새로 만들어 추가한다.
    @NotBlank
    private String email;
}
