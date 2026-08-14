package com.parttime.api.domain.worklog.repository;

import com.parttime.api.entity.WorkLog;
import org.springframework.data.jpa.repository.JpaRepository;

import java.time.LocalDate;
import java.util.List;

public interface WorkLogRepository extends JpaRepository<WorkLog, Long> {
    List<WorkLog> findByWorkplaceIdOrderByCreatedAtDesc(Long workplaceId);

    List<WorkLog> findByWorkerIdAndWorkRecordIdInAndActionIn(
        Long workerId, List<Long> workRecordIds, List<WorkLog.Action> actions);

    List<WorkLog> findByWorkerIdAndActionAndRecordDateBetween(
        Long workerId, WorkLog.Action action, LocalDate start, LocalDate end);

    // 근무지 전체(여러 근로자) 기록을 다루는 사장용 화면(근무 총 내역/근무 상세)에서 쓴다 —
    // workRecordId 자체가 이미 유일하므로 근로자로 다시 좁힐 필요가 없다.
    List<WorkLog> findByWorkRecordIdInAndActionIn(
        List<Long> workRecordIds, List<WorkLog.Action> actions);
}
