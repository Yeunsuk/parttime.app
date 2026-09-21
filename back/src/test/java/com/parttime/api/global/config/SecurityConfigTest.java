package com.parttime.api.global.config;

import com.parttime.api.domain.auth.controller.AuthController;
import com.parttime.api.domain.auth.service.AuthService;
import com.parttime.api.global.jwt.JwtProvider;
import com.parttime.api.global.security.ClientIpResolver;
import com.parttime.api.global.security.LoginAttemptService;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.webmvc.test.autoconfigure.WebMvcTest;
import org.springframework.context.annotation.Import;
import org.springframework.test.context.bean.override.mockito.MockitoBean;
import org.springframework.test.web.servlet.MockMvc;

import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

// 프론트(dio 인터셉터)는 401일 때만 리프레시 토큰으로 재발급한다. 인증 실패가 403으로
// 내려가면 액세스 토큰이 만료될 때마다 재로그인해야 하므로 401인지 고정해서 검증한다.
@WebMvcTest(AuthController.class)
@Import(SecurityConfig.class)
class SecurityConfigTest {

    @Autowired
    private MockMvc mockMvc;

    @MockitoBean
    private JwtProvider jwtProvider;
    @MockitoBean
    private LoginAttemptService loginAttemptService;
    @MockitoBean
    private ClientIpResolver clientIpResolver;
    @MockitoBean
    private AuthService authService;

    @Test
    void 토큰_없이_보호된_경로를_호출하면_401() throws Exception {
        mockMvc.perform(get("/api/auth/me"))
            .andExpect(status().isUnauthorized());
    }

    @Test
    void 만료되거나_무효한_토큰이면_401() throws Exception {
        // JwtProvider mock의 isValid는 기본 false — 만료/변조된 토큰과 같은 상황.
        mockMvc.perform(get("/api/auth/me").header("Authorization", "Bearer expired.or.invalid"))
            .andExpect(status().isUnauthorized());
    }
}
