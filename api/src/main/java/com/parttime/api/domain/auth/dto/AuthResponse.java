package com.parttime.api.domain.auth.dto;

import com.parttime.api.entity.User;
import lombok.Getter;

@Getter
public class AuthResponse {

    private final String accessToken;
    private final String refreshToken;
    private final UserResponse user;

    public AuthResponse(String accessToken, String refreshToken, User user) {
        this.accessToken = accessToken;
        this.refreshToken = refreshToken;
        this.user = new UserResponse(user);
    }
}
