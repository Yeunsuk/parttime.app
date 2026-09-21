package com.parttime.api.domain.auth.dto;

import com.parttime.api.domain.workplace.dto.WorkplaceResponse;
import com.parttime.api.entity.User;
import lombok.Getter;

import java.util.List;

@Getter
public class AuthResponse {

    private final String accessToken;
    private final String refreshToken;
    private final UserResponse user;
    // 로그인/회원가입 직후 프론트가 곧바로 근무지 목록을 다시 요청하지 않아도 되도록 같이 내려준다
    // (왕복 한 번 절약). 리프레시 응답에서는 필요 없어서 null.
    private final List<WorkplaceResponse> workplaces;

    public AuthResponse(String accessToken, String refreshToken, User user) {
        this(accessToken, refreshToken, user, null);
    }

    public AuthResponse(String accessToken, String refreshToken, User user,
                        List<WorkplaceResponse> workplaces) {
        this.accessToken = accessToken;
        this.refreshToken = refreshToken;
        this.user = new UserResponse(user);
        this.workplaces = workplaces;
    }
}
