package com.parttime.api.domain.auth.service;

import com.parttime.api.domain.auth.dto.AuthResponse;
import com.parttime.api.domain.auth.dto.LoginRequest;
import com.parttime.api.domain.auth.dto.SignupRequest;
import com.parttime.api.domain.auth.repository.UserRepository;
import com.parttime.api.domain.workplace.dto.WorkplaceResponse;
import com.parttime.api.domain.workplace.service.WorkplaceService;
import com.parttime.api.entity.User;
import com.parttime.api.global.jwt.JwtProvider;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.test.util.ReflectionTestUtils;

import java.util.List;
import java.util.Optional;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.verifyNoInteractions;
import static org.mockito.Mockito.when;

// 순수 단위 테스트 — 로그인/회원가입 응답에 근무지 목록이 실려 나가는지(프론트가 로그인 직후
// /workplaces/my를 다시 부르지 않게 하려는 것)와, 리프레시 응답에는 실리지 않는지를 확인한다.
class AuthServiceTest {

    private UserRepository userRepository;
    private PasswordEncoder passwordEncoder;
    private JwtProvider jwtProvider;
    private WorkplaceService workplaceService;
    private AuthService authService;
    private User owner;

    @BeforeEach
    void setUp() {
        userRepository = mock(UserRepository.class);
        passwordEncoder = mock(PasswordEncoder.class);
        jwtProvider = mock(JwtProvider.class);
        workplaceService = mock(WorkplaceService.class);
        authService = new AuthService(userRepository, passwordEncoder, jwtProvider, workplaceService);

        owner = User.builder()
            .email("owner@test.com").password("hash").name("사장").role(User.Role.OWNER).build();
        ReflectionTestUtils.setField(owner, "id", 1L);

        when(jwtProvider.generateToken(1L, "OWNER")).thenReturn("access");
        when(jwtProvider.generateRefreshToken(1L, "OWNER")).thenReturn("refresh");
    }

    @Test
    void 로그인_응답에_내_근무지_목록이_실린다() {
        LoginRequest req = mock(LoginRequest.class);
        when(req.getEmail()).thenReturn("owner@test.com");
        when(req.getPassword()).thenReturn("pw");
        when(userRepository.findByEmail("owner@test.com")).thenReturn(Optional.of(owner));
        when(passwordEncoder.matches("pw", "hash")).thenReturn(true);
        WorkplaceResponse workplace = mock(WorkplaceResponse.class);
        when(workplaceService.getMyWorkplaces(1L, "OWNER")).thenReturn(List.of(workplace));

        AuthResponse res = authService.login(req);

        assertThat(res.getAccessToken()).isEqualTo("access");
        assertThat(res.getWorkplaces()).containsExactly(workplace);
    }

    @Test
    void 회원가입_응답의_근무지_목록은_빈_배열이다() {
        SignupRequest req = mock(SignupRequest.class);
        when(req.getEmail()).thenReturn("owner@test.com");
        when(req.getPassword()).thenReturn("pw");
        when(req.getName()).thenReturn("사장");
        when(req.getRole()).thenReturn("WORKER");
        when(userRepository.existsByEmail("owner@test.com")).thenReturn(false);
        when(passwordEncoder.encode("pw")).thenReturn("hash");
        when(userRepository.save(any(User.class))).thenAnswer(inv -> {
            User saved = inv.getArgument(0);
            ReflectionTestUtils.setField(saved, "id", 1L);
            return saved;
        });
        when(jwtProvider.generateToken(1L, "WORKER")).thenReturn("access");
        when(jwtProvider.generateRefreshToken(1L, "WORKER")).thenReturn("refresh");

        AuthResponse res = authService.signup(req);

        assertThat(res.getWorkplaces()).isEmpty();
        verifyNoInteractions(workplaceService);
    }

    @Test
    void 리프레시_응답에는_근무지_목록이_없다() {
        when(jwtProvider.isValid("old-refresh")).thenReturn(true);
        when(jwtProvider.isRefreshToken("old-refresh")).thenReturn(true);
        when(jwtProvider.getUserId("old-refresh")).thenReturn(1L);
        when(userRepository.findById(1L)).thenReturn(Optional.of(owner));

        AuthResponse res = authService.refresh("old-refresh");

        assertThat(res.getWorkplaces()).isNull();
        verifyNoInteractions(workplaceService);
    }
}
