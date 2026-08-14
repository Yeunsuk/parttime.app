package com.parttime.api.domain.worklog.service;

import com.parttime.api.domain.worklog.repository.WorkLogRepository;
import com.parttime.api.entity.User;
import com.parttime.api.entity.WorkLog;
import com.parttime.api.entity.Workplace;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;

// 다른 서비스(출퇴근, 근무기록 추가/수정)에서 호출하는 로그 기록용 헬퍼.
@Service
@RequiredArgsConstructor
public class WorkLogService {

    private final WorkLogRepository workLogRepository;

    @Transactional
    public void log(Workplace workplace, User worker, User actor, Long workRecordId,
                     LocalDate recordDate, WorkLog.Action action, String message) {
        workLogRepository.save(WorkLog.builder()
            .workplace(workplace)
            .worker(worker)
            .actor(actor)
            .workRecordId(workRecordId)
            .recordDate(recordDate)
            .action(action)
            .message(message)
            .build());
    }
}
