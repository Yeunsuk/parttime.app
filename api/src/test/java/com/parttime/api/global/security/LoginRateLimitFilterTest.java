package com.parttime.api.global.security;

import jakarta.servlet.FilterChain;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.mock.web.MockHttpServletRequest;
import org.springframework.mock.web.MockHttpServletResponse;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.times;
import static org.mockito.Mockito.verify;

// 순수 단위 테스트 — Spring 컨텍스트/DB 없이 필터+서비스만 직접 조립해서 검증한다.
// AuthController.login()이 실패 시 호출하는 LoginAttemptService.recordFailure(ip)를
// 그대로 흉내내서, "동일 IP로 maxRetry번 실패하면 이후 요청이 429로 막히는지"를 확인한다.
class LoginRateLimitFilterTest {

    private static final String LOGIN_PATH = "/api/auth/login";
    private static final String CLIENT_IP = "203.0.113.10";

    private LoginRateLimitProperties properties;
    private LoginAttemptService loginAttemptService;
    private LoginRateLimitFilter filter;

    @BeforeEach
    void setUp() {
        properties = new LoginRateLimitProperties();
        properties.setMaxRetry(5);
        properties.setFindTimeMinutes(10);
        properties.setBanTimeMinutes(15);

        // DB 없이 순수 단위 테스트로 유지 — 로그 영속화는 여기서 검증 대상이 아니라 mock으로 흘려보낸다.
        loginAttemptService = new LoginAttemptService(properties, mock(LoginAttemptLogRepository.class));
        filter = new LoginRateLimitFilter(loginAttemptService, new ClientIpResolver());
    }

    private MockHttpServletRequest loginRequest(String clientIp) {
        MockHttpServletRequest request = new MockHttpServletRequest("POST", LOGIN_PATH);
        request.addHeader("X-Forwarded-For", clientIp);
        return request;
    }

    @Test
    void 실패_횟수가_임계치에_도달하면_이후_로그인_요청이_429로_차단된다() throws Exception {
        // AuthController.login()이 실패할 때마다 호출하는 것과 동일하게 maxRetry번 실패를 기록
        for (int i = 0; i < properties.getMaxRetry(); i++) {
            loginAttemptService.recordFailure(CLIENT_IP);
        }

        MockHttpServletResponse response = new MockHttpServletResponse();
        FilterChain chain = mock(FilterChain.class);

        filter.doFilterInternal(loginRequest(CLIENT_IP), response, chain);

        assertThat(response.getStatus()).isEqualTo(429);
        assertThat(response.getHeader("Retry-After")).isNotNull();
        assertThat(response.getContentAsString()).contains("retryAfterSeconds");
        verify(chain, never()).doFilter(any(), any());
    }

    @Test
    void 실패_횟수가_임계치_미만이면_요청이_그대로_통과된다() throws Exception {
        for (int i = 0; i < properties.getMaxRetry() - 1; i++) {
            loginAttemptService.recordFailure(CLIENT_IP);
        }

        MockHttpServletRequest request = loginRequest(CLIENT_IP);
        MockHttpServletResponse response = new MockHttpServletResponse();
        FilterChain chain = mock(FilterChain.class);

        filter.doFilterInternal(request, response, chain);

        verify(chain, times(1)).doFilter(request, response);
    }

    @Test
    void 로그인_성공으로_초기화되면_다시_maxRetry번_실패해야_차단된다() throws Exception {
        for (int i = 0; i < properties.getMaxRetry() - 1; i++) {
            loginAttemptService.recordFailure(CLIENT_IP);
        }
        loginAttemptService.recordSuccess(CLIENT_IP);

        // 초기화 이후 1번만 더 실패해도(원래는 maxRetry번째였을) 아직 차단되면 안 된다
        loginAttemptService.recordFailure(CLIENT_IP);

        MockHttpServletResponse response = new MockHttpServletResponse();
        FilterChain chain = mock(FilterChain.class);
        filter.doFilterInternal(loginRequest(CLIENT_IP), response, chain);

        verify(chain, times(1)).doFilter(any(), any());
    }

    @Test
    void 다른_IP의_실패는_서로_영향을_주지_않는다() throws Exception {
        String otherIp = "198.51.100.20";
        for (int i = 0; i < properties.getMaxRetry(); i++) {
            loginAttemptService.recordFailure(otherIp);
        }

        MockHttpServletResponse response = new MockHttpServletResponse();
        FilterChain chain = mock(FilterChain.class);
        filter.doFilterInternal(loginRequest(CLIENT_IP), response, chain);

        verify(chain, times(1)).doFilter(any(), any());
    }

    @Test
    void 로그인_경로가_아니면_실패_기록과_무관하게_항상_통과된다() throws Exception {
        for (int i = 0; i < properties.getMaxRetry(); i++) {
            loginAttemptService.recordFailure(CLIENT_IP);
        }

        MockHttpServletRequest request = new MockHttpServletRequest("GET", "/api/auth/me");
        request.addHeader("X-Forwarded-For", CLIENT_IP);
        MockHttpServletResponse response = new MockHttpServletResponse();
        FilterChain chain = mock(FilterChain.class);

        filter.doFilterInternal(request, response, chain);

        verify(chain, times(1)).doFilter(request, response);
    }
}
