package com.parttime.api.domain.auth.service;

import com.parttime.api.domain.auth.dto.AuthResponse;
import com.parttime.api.domain.auth.dto.LoginRequest;
import com.parttime.api.domain.auth.dto.SignupRequest;
import com.parttime.api.domain.auth.dto.UserResponse;
import com.parttime.api.domain.auth.repository.UserRepository;
import com.parttime.api.entity.User;
import com.parttime.api.global.exception.BusinessException;
import com.parttime.api.global.exception.ErrorCode;
import com.parttime.api.global.jwt.JwtProvider;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
public class AuthService {

    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;
    private final JwtProvider jwtProvider;

    // 사장 계정 가입 시 요구되는 인증코드 (아무나 사장으로 가입하지 못하도록 막는 용도)
    @Value("${auth.owner-auth-code}")
    private String ownerAuthCode;

    @Transactional
    public AuthResponse signup(SignupRequest req) {
        if (userRepository.existsByEmail(req.getEmail())) {
            throw new BusinessException(ErrorCode.DUPLICATE_EMAIL);
        }

        if ("OWNER".equals(req.getRole()) && !ownerAuthCode.equals(req.getOwnerAuthCode())) {
            throw new BusinessException(ErrorCode.INVALID_OWNER_AUTH_CODE);
        }

        User user = User.builder()
            .email(req.getEmail())
            .password(passwordEncoder.encode(req.getPassword()))
            .name(req.getName())
            .role(User.Role.valueOf(req.getRole()))
            .build();

        userRepository.save(user);

        return issueTokens(user);
    }

    @Transactional(readOnly = true)
    public AuthResponse login(LoginRequest req) {
        User user = userRepository.findByEmail(req.getEmail())
            .orElseThrow(() -> new BusinessException(ErrorCode.INVALID_CREDENTIALS));

        if (!passwordEncoder.matches(req.getPassword(), user.getPassword())) {
            throw new BusinessException(ErrorCode.INVALID_CREDENTIALS);
        }

        return issueTokens(user);
    }

    // 리프레시 토큰으로 액세스 토큰 재발급 (리프레시 토큰도 함께 회전)
    @Transactional(readOnly = true)
    public AuthResponse refresh(String refreshToken) {
        if (!jwtProvider.isValid(refreshToken) || !jwtProvider.isRefreshToken(refreshToken)) {
            throw new BusinessException(ErrorCode.INVALID_REFRESH_TOKEN);
        }

        Long userId = jwtProvider.getUserId(refreshToken);
        User user = userRepository.findById(userId)
            .orElseThrow(() -> new BusinessException(ErrorCode.USER_NOT_FOUND));

        return issueTokens(user);
    }

    // 액세스 토큰으로 현재 로그인된 유저 정보 조회 (세션 복원용)
    @Transactional(readOnly = true)
    public UserResponse getMe(Long userId) {
        User user = userRepository.findById(userId)
            .orElseThrow(() -> new BusinessException(ErrorCode.USER_NOT_FOUND));
        return new UserResponse(user);
    }

    private AuthResponse issueTokens(User user) {
        String accessToken = jwtProvider.generateToken(user.getId(), user.getRole().name());
        String refreshToken = jwtProvider.generateRefreshToken(user.getId(), user.getRole().name());
        return new AuthResponse(accessToken, refreshToken, user);
    }
}
