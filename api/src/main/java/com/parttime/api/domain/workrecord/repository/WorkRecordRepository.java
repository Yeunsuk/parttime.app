package com.parttime.api.domain.workrecord.repository;

import com.parttime.api.entity.WorkRecord;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;

public interface WorkRecordRepository extends JpaRepository<WorkRecord, Long> {

    // 현재 출근 중인 기록 (clockOut == null)
    Optional<WorkRecord> findByWorkerIdAndClockOutIsNull(Long workerId);

    // 월별 근무기록
    List<WorkRecord> findByWorkerIdAndClockInBetween(
        Long workerId,
        java.time.LocalDateTime start,
        java.time.LocalDateTime end
    );

    // 사장용 - 근무지 + 근로자 + 월별
    List<WorkRecord> findByWorkplaceIdAndWorkerIdAndClockInBetween(
        Long workplaceId,
        Long workerId,
        java.time.LocalDateTime start,
        java.time.LocalDateTime end
    );

    // 사장용 - 근무지 + 월별 (전체 근로자)
    List<WorkRecord> findByWorkplaceIdAndClockInBetween(
        Long workplaceId,
        java.time.LocalDateTime start,
        java.time.LocalDateTime end
    );
}
