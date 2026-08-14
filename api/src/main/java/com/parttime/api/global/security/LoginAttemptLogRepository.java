package com.parttime.api.global.security;

import com.parttime.api.entity.LoginAttemptLog;
import org.springframework.data.jpa.repository.JpaRepository;

// admin-tool이 psycopg2로 login_attempt_logs 테이블을 직접 조회하므로, 여기서는
// 저장(LoginAttemptService)에만 쓰고 별도 조회 메서드는 필요 없다.
public interface LoginAttemptLogRepository extends JpaRepository<LoginAttemptLog, Long> {
}
