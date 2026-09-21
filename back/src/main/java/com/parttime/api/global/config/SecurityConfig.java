package com.parttime.api.global.config;

import com.parttime.api.global.jwt.JwtFilter;
import com.parttime.api.global.jwt.JwtProvider;
import com.parttime.api.global.security.ClientIpResolver;
import com.parttime.api.global.security.LoginAttemptService;
import com.parttime.api.global.security.LoginRateLimitFilter;
import lombok.RequiredArgsConstructor;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.http.HttpStatus;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.config.annotation.web.configurers.AbstractHttpConfigurer;
import org.springframework.security.config.http.SessionCreationPolicy;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.security.web.authentication.HttpStatusEntryPoint;
import org.springframework.security.web.authentication.UsernamePasswordAuthenticationFilter;
import org.springframework.web.cors.CorsConfiguration;
import org.springframework.web.cors.CorsConfigurationSource;
import org.springframework.web.cors.UrlBasedCorsConfigurationSource;

import java.util.List;

@Configuration
@EnableWebSecurity
@RequiredArgsConstructor
public class SecurityConfig {

    private final JwtProvider jwtProvider;
    private final LoginAttemptService loginAttemptService;
    private final ClientIpResolver clientIpResolver;

    @Bean
    public PasswordEncoder passwordEncoder() {
        return new BCryptPasswordEncoder();
    }

    @Bean
    public SecurityFilterChain filterChain(HttpSecurity http) throws Exception {
        return http
            .csrf(AbstractHttpConfigurer::disable)
            // Flutter web 클라이언트가 브라우저에서 이 API를 직접 호출하므로 CORS를 열어둔다.
            // 인증은 쿠키가 아니라 Authorization 헤더의 Bearer 토큰으로 하기 때문에
            // origin을 넓게 허용해도 CSRF/자격증명 탈취 위험은 없다.
            .cors(c -> c.configurationSource(corsConfigurationSource()))
            .sessionManagement(s ->
                s.sessionCreationPolicy(SessionCreationPolicy.STATELESS))
            // 토큰이 없거나 만료/무효면 JwtFilter가 인증 없이 통과시키고, 스프링 기본값은 이 경우
            // 403을 준다. 프론트(dio 인터셉터)는 401일 때만 리프레시 토큰으로 재발급하므로,
            // 403이면 액세스 토큰(24시간)이 만료될 때마다 리프레시 토큰(14일)을 못 쓰고
            // 다시 로그인하게 된다 — 인증 실패는 401로 내려준다.
            .exceptionHandling(e ->
                e.authenticationEntryPoint(new HttpStatusEntryPoint(HttpStatus.UNAUTHORIZED)))
            .authorizeHttpRequests(auth -> auth
                .requestMatchers("/api/auth/signup", "/api/auth/login", "/api/auth/refresh").permitAll()
                .requestMatchers("/api/**").authenticated()
                // /api/** 이외(정적으로 서빙되는 Flutter web 빌드 산출물: index.html, JS 번들 등)는
                // 로그인 전에도 페이지 자체는 열려야 하므로 인증을 요구하지 않는다.
                .anyRequest().permitAll()
            )
            .addFilterBefore(
                new JwtFilter(jwtProvider),
                UsernamePasswordAuthenticationFilter.class
            )
            // 로그인 브루트포스 방어: 차단된 IP는 JwtFilter/컨트롤러까지 가지 않고 여기서 끊는다.
            .addFilterBefore(
                new LoginRateLimitFilter(loginAttemptService, clientIpResolver),
                JwtFilter.class
            )
            .build();
    }

    private CorsConfigurationSource corsConfigurationSource() {
        CorsConfiguration config = new CorsConfiguration();
        config.setAllowedOriginPatterns(List.of("*"));
        config.setAllowedMethods(List.of("GET", "POST", "PATCH", "PUT", "DELETE", "OPTIONS"));
        config.setAllowedHeaders(List.of("*"));
        UrlBasedCorsConfigurationSource source = new UrlBasedCorsConfigurationSource();
        source.registerCorsConfiguration("/**", config);
        return source;
    }
}
