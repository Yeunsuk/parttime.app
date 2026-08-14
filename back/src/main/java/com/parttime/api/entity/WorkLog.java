package com.parttime.api.entity;

import jakarta.persistence.*;
import lombok.*;
import org.springframework.data.annotation.CreatedDate;
import org.springframework.data.jpa.domain.support.AuditingEntityListener;

import java.time.LocalDate;
import java.time.LocalDateTime;

// 근무지 활동 로그 (출퇴근/근무기록 추가·수정). WorkRecord는 "현재 상태"만 갖고 있어서
// 나중에 수정되면 이전 값이 사라지므로, 무슨 일이 언제 있었는지 지우지 않고 쌓아두는 이력이다.
// WorkRecord가 나중에 삭제되더라도(예: 30분 미만 근무) 로그는 그대로 남아야 하므로
// workRecord를 외래키로 강하게 물지 않고 id만 참조로 남긴다.
@Entity
@Table(name = "work_logs")
@Getter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
@EntityListeners(AuditingEntityListener.class)
public class WorkLog {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "workplace_id", nullable = false)
    private Workplace workplace;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "worker_id", nullable = false)
    private User worker;

    // 이 이벤트를 발생시킨 사람: 출퇴근은 근로자 본인, 근무기록 추가/수정은 사장
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "actor_id", nullable = false)
    private User actor;

    private Long workRecordId;

    // 이 로그가 다루는 근무기록의 근무일(clockIn 날짜). WorkLog.createdAt(로그가 실제
    // 남겨진 시각)과는 다를 수 있다 — 예: 사장이 지난주 근무기록을 오늘 삭제하면
    // createdAt은 오늘이지만 recordDate는 지난주 그 날짜다. "개인 근무내역" 화면에서
    // "그 날짜에 삭제된 적이 있는지"를 판단할 때는 반드시 이 값을 써야 한다.
    private LocalDate recordDate;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private Action action;

    @Column(nullable = false, length = 500)
    private String message;

    @CreatedDate
    private LocalDateTime createdAt;

    public enum Action { CLOCK_IN, CLOCK_OUT, RECORD_ADDED, RECORD_MODIFIED, RECORD_DELETED }

    @Builder
    public WorkLog(Workplace workplace, User worker, User actor, Long workRecordId,
                    LocalDate recordDate, Action action, String message) {
        this.workplace = workplace;
        this.worker = worker;
        this.actor = actor;
        this.workRecordId = workRecordId;
        this.recordDate = recordDate;
        this.action = action;
        this.message = message;
    }
}
