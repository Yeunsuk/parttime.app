package com.parttime.api.entity;

import jakarta.persistence.*;
import lombok.*;
import org.springframework.data.annotation.CreatedDate;
import org.springframework.data.jpa.domain.support.AuditingEntityListener;

import java.time.LocalDateTime;

// 로그인 브루트포스 방어(LoginAttemptService)의 IP별 실패/차단/초기화 이력. 인메모리
// 카운터(attemptsByIp)는 재배포 시 초기화되지만, 이 로그는 DB에 남아 admin-tool에서
// "차단 IP 목록/빈도"를 조회할 수 있게 한다. 차단 중에 반복되는 BLOCKED(429) 응답은
// 공격자가 계속 두드리면 순식간에 대량으로 쌓일 수 있어 여기 남기지 않는다 — BANNED
// 하나로 "언제 몇 번 실패해서 차단됐는지"는 이미 충분히 알 수 있다.
@Entity
@Table(name = "login_attempt_logs")
@Getter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
@EntityListeners(AuditingEntityListener.class)
public class LoginAttemptLog {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false, length = 64)
    private String clientIp;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private Event event;

    // FAILURE/BANNED 시점까지 누적된 실패 횟수. RESET에서는 null.
    private Integer recentFailures;

    @CreatedDate
    private LocalDateTime createdAt;

    public enum Event { FAILURE, BANNED, RESET }

    @Builder
    public LoginAttemptLog(String clientIp, Event event, Integer recentFailures) {
        this.clientIp = clientIp;
        this.event = event;
        this.recentFailures = recentFailures;
    }
}
