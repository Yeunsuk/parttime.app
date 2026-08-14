package com.parttime.api.global.security;

import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.MediaType;
import org.springframework.web.filter.OncePerRequestFilter;

import java.io.IOException;
import java.time.Instant;

// 로그인 엔드포인트(POST /api/auth/login) 전용 브루트포스 방어 필터. 실제 실패/성공
// 카운트는 AuthController.login()에서 LoginAttemptService에 직접 기록하고, 이 필터는
// "지금 이 IP가 차단 중인가"만 확인해서 맞으면 컨트롤러까지 가지도 않고 바로 429로
// 끊어버린다 — 어차피 차단된 요청이 DB 조회(회원 조회, 비밀번호 검증)까지 갈 필요가 없다.
//
// SecurityConfig에서 JwtFilter보다 앞에 등록한다: /api/auth/login은 permitAll이라
// JwtFilter는 사실상 아무 일도 안 하지만, 차단 여부는 인증 로직보다도 먼저 걸러내는 게
// 자연스럽다.
@Slf4j
@RequiredArgsConstructor
public class LoginRateLimitFilter extends OncePerRequestFilter {

    private static final String LOGIN_PATH = "/api/auth/login";

    private final LoginAttemptService loginAttemptService;
    private final ClientIpResolver clientIpResolver;

    @Override
    protected void doFilterInternal(HttpServletRequest request, HttpServletResponse response,
                                     FilterChain chain) throws ServletException, IOException {

        if (!isLoginRequest(request)) {
            chain.doFilter(request, response);
            return;
        }

        String clientIp = clientIpResolver.resolve(request);
        var banRemaining = loginAttemptService.getBanRemainingSeconds(clientIp);

        if (banRemaining.isPresent()) {
            long retryAfterSeconds = banRemaining.get();
            log.warn("[LOGIN-RATE-LIMIT] BLOCKED ip={} retryAfterSeconds={}", clientIp, retryAfterSeconds);
            writeTooManyRequests(response, retryAfterSeconds);
            return;
        }

        chain.doFilter(request, response);
    }

    private boolean isLoginRequest(HttpServletRequest request) {
        return "POST".equalsIgnoreCase(request.getMethod()) && LOGIN_PATH.equals(request.getRequestURI());
    }

    // 값이 전부 서버가 계산한 숫자/타임스탬프뿐이라(사용자 입력 없음) JSON 이스케이프가
    // 필요 없어, 별도 JSON 라이브러리 의존 없이 문자열로 직접 만든다.
    private void writeTooManyRequests(HttpServletResponse response, long retryAfterSeconds) throws IOException {
        // jakarta.servlet.http.HttpServletResponse에는 429(Too Many Requests) 상수가
        // 없어서(서블릿 스펙이 HTTP/1.1 제정 당시 코드만 정의) 숫자를 직접 쓴다.
        response.setStatus(429);
        response.setHeader("Retry-After", String.valueOf(retryAfterSeconds));
        response.setContentType(MediaType.APPLICATION_JSON_VALUE);
        response.setCharacterEncoding("UTF-8");

        String retryAt = Instant.now().plusSeconds(retryAfterSeconds).toString();
        String message = "로그인 시도가 너무 많습니다. " + retryAfterSeconds + "초 후 다시 시도해주세요.";

        // 기존 ApiResponse<T> 봉투(success/data/message)와 형태를 맞춰서 프론트가 다른
        // 응답과 동일하게 파싱할 수 있게 한다.
        String json = "{"
            + "\"success\":false,"
            + "\"data\":{"
            + "\"retryAfterSeconds\":" + retryAfterSeconds + ","
            + "\"retryAt\":\"" + retryAt + "\""
            + "},"
            + "\"message\":\"" + message + "\""
            + "}";

        response.getWriter().write(json);
    }
}
