package com.parttime.api.global.config;

import com.parttime.api.global.jwt.JwtFilter;
import com.parttime.api.global.jwt.JwtProvider;
import com.parttime.api.global.security.ClientIpResolver;
import com.parttime.api.global.security.LoginAttemptService;
import com.parttime.api.global.security.LoginRateLimitFilter;
import lombok.RequiredArgsConstructor;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.config.annotation.web.configurers.AbstractHttpConfigurer;
import org.springframework.security.config.http.SessionCreationPolicy;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.security.web.SecurityFilterChain;
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
