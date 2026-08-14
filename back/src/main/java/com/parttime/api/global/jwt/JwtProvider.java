package com.parttime.api.global.jwt;

import io.jsonwebtoken.*;
import io.jsonwebtoken.security.Keys;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;

import javax.crypto.SecretKey;
import java.nio.charset.StandardCharsets;
import java.util.Date;

@Component
@RequiredArgsConstructor
public class JwtProvider {

    private final JwtProperties jwtProperties;

    private SecretKey getKey() {
        return Keys.hmacShaKeyFor(
            jwtProperties.getSecret().getBytes(StandardCharsets.UTF_8)
        );
    }

    public String generateToken(Long userId, String role) {
        return buildToken(userId, role, jwtProperties.getExpiration(), "access");
    }

    public String generateRefreshToken(Long userId, String role) {
        return buildToken(userId, role, jwtProperties.getRefreshExpiration(), "refresh");
    }

    private String buildToken(Long userId, String role, long expirationMs, String type) {
        return Jwts.builder()
            .subject(String.valueOf(userId))
            .claim("role", role)
            .claim("type", type)
            .issuedAt(new Date())
            .expiration(new Date(System.currentTimeMillis() + expirationMs))
            .signWith(getKey())
            .compact();
    }

    public boolean isRefreshToken(String token) {
        return "refresh".equals(getClaims(token).get("type", String.class));
    }

    public boolean isAccessToken(String token) {
        return "access".equals(getClaims(token).get("type", String.class));
    }

    public Claims getClaims(String token) {
        return Jwts.parser()
            .verifyWith(getKey())
            .build()
            .parseSignedClaims(token)
            .getPayload();
    }

    public boolean isValid(String token) {
        try {
            getClaims(token);
            return true;
        } catch (JwtException | IllegalArgumentException e) {
            return false;
        }
    }

    public Long getUserId(String token) {
        return Long.valueOf(getClaims(token).getSubject());
    }

    public String getRole(String token) {
        return getClaims(token).get("role", String.class);
    }
}
