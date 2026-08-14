package com.parttime.api.global.security;

import lombok.Getter;
import lombok.Setter;
import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.stereotype.Component;

// 로그인 브루트포스 방어(fail2ban 스타일) 설정값. 기본값은 findtime 10분 안에 5회
// 실패하면 15분 차단.
@Getter
@Setter
@Component
@ConfigurationProperties(prefix = "security.login-rate-limit")
public class LoginRateLimitProperties {
    private int maxRetry = 5;
    private int findTimeMinutes = 10;
    private int banTimeMinutes = 15;
}
