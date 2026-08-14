package com.parttime.api.global.security;

import com.parttime.api.entity.LoginAttemptLog;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Transactional;

import java.time.Duration;
import java.time.Instant;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;
import java.util.concurrent.ConcurrentHashMap;

// IP별 로그인 실패 횟수를 인메모리로 세고, findTime 안에 maxRetry번 실패하면 banTime 동안
// 차단한다(fail2ban과 동일한 개념). 차단 판정 자체는 이 인메모리 카운터로만 하고(재배포 시
// 초기화되는 점은 감수하는 트레이드오프), 별도로 DB(login_attempt_logs)에도 이벤트를 남겨서
// admin-tool에서 "차단 IP 목록/빈도"를 이력으로 조회할 수 있게 한다.
@Slf4j
@Component
@RequiredArgsConstructor
public class LoginAttemptService {

    private final LoginRateLimitProperties properties;
    private final LoginAttemptLogRepository loginAttemptLogRepository;

    private final ConcurrentHashMap<String, AttemptRecord> attemptsByIp = new ConcurrentHashMap<>();

    // 지금 차단 중이면 남은 차단 시간(초)을 반환하고, 아니면 비어있는 Optional을 반환한다.
    // 차단이 이미 끝난 기록은 여기서 청소한다(다음 시도 때 완전히 새로 센다).
    public Optional<Long> getBanRemainingSeconds(String clientIp) {
        AttemptRecord record = attemptsByIp.get(clientIp);
        if (record == null) {
            return Optional.empty();
        }

        synchronized (record) {
            if (record.bannedUntil == null) {
                return Optional.empty();
            }
            long remaining = Duration.between(Instant.now(), record.bannedUntil).getSeconds();
            if (remaining <= 0) {
                attemptsByIp.remove(clientIp);
                return Optional.empty();
            }
            return Optional.of(remaining);
        }
    }

    // 로그인 실패 시 호출한다. findTime 밖으로 벗어난 오래된 실패는 버리고, 남은 실패
    // 횟수가 maxRetry 이상이면 차단을 건다.
    @Transactional
    public void recordFailure(String clientIp) {
        Instant now = Instant.now();
        AttemptRecord record = attemptsByIp.computeIfAbsent(clientIp, k -> new AttemptRecord());

        int recentFailures;
        boolean justBanned = false;
        Instant bannedUntil = null;

        synchronized (record) {
            record.failureTimestamps.removeIf(
                t -> Duration.between(t, now).toMinutes() >= properties.getFindTimeMinutes());
            record.failureTimestamps.add(now);
            recentFailures = record.failureTimestamps.size();

            if (recentFailures >= properties.getMaxRetry() && record.bannedUntil == null) {
                record.bannedUntil = now.plus(Duration.ofMinutes(properties.getBanTimeMinutes()));
                justBanned = true;
                bannedUntil = record.bannedUntil;
            }
        }

        if (justBanned) {
            log.warn("[LOGIN-RATE-LIMIT] BANNED ip={} recentFailures={} findTimeMinutes={} "
                    + "banTimeMinutes={} bannedUntil={}",
                clientIp, recentFailures, properties.getFindTimeMinutes(),
                properties.getBanTimeMinutes(), bannedUntil);
            loginAttemptLogRepository.save(LoginAttemptLog.builder()
                .clientIp(clientIp).event(LoginAttemptLog.Event.BANNED)
                .recentFailures(recentFailures).build());
        } else {
            log.info("[LOGIN-RATE-LIMIT] FAILURE ip={} recentFailures={}/{}",
                clientIp, recentFailures, properties.getMaxRetry());
            loginAttemptLogRepository.save(LoginAttemptLog.builder()
                .clientIp(clientIp).event(LoginAttemptLog.Event.FAILURE)
                .recentFailures(recentFailures).build());
        }
    }

    // 로그인 성공 시 호출한다. 그 IP의 실패 이력/차단 상태를 전부 초기화한다.
    @Transactional
    public void recordSuccess(String clientIp) {
        AttemptRecord removed = attemptsByIp.remove(clientIp);
        if (removed != null) {
            log.info("[LOGIN-RATE-LIMIT] RESET ip={} (로그인 성공으로 실패 카운터 초기화)", clientIp);
            loginAttemptLogRepository.save(LoginAttemptLog.builder()
                .clientIp(clientIp).event(LoginAttemptLog.Event.RESET).build());
        }
    }

    private static class AttemptRecord {
        private final List<Instant> failureTimestamps = new ArrayList<>();
        private volatile Instant bannedUntil;
    }
}
