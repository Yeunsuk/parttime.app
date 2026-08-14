package com.parttime.api.entity;

import jakarta.persistence.*;
import lombok.*;
import org.springframework.data.annotation.CreatedDate;
import org.springframework.data.jpa.domain.support.AuditingEntityListener;

import java.time.LocalDateTime;

@Entity
@Table(name = "work_records")
@Getter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
@EntityListeners(AuditingEntityListener.class)
public class WorkRecord {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "workplace_id", nullable = false)
    private Workplace workplace;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "worker_id", nullable = false)
    private User worker;

    @Column(nullable = false)
    private LocalDateTime clockIn;

    private LocalDateTime clockOut;

    private Integer workMinutes;

    private Integer wageAmount;

    @Column(nullable = false)
    private Boolean isModified = false;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "modified_by")
    private User modifiedBy;

    // 생성 시점 직원의 정산 방식을 그대로 찍어둔다 — 나중에 직원의 정산방식 설정이 바뀌어도
    // 이미 만들어진 기록의 표시 방식은 그대로 유지되어야 하므로. null이면(기존 기록) TIME으로 취급한다.
    @Enumerated(EnumType.STRING)
    private PaymentType paymentType;

    // 횟수제(COUNT) 기록 1건이 몇 회로 집계되는지 (1 또는 0.5). null이면(시간제 기록 등) 1회로 취급한다.
    private Double recordCount;

    @CreatedDate
    private LocalDateTime createdAt;

    @Builder
    public WorkRecord(Workplace workplace, User worker, LocalDateTime clockIn,
                       PaymentType paymentType, Double recordCount) {
        this.workplace = workplace;
        this.worker = worker;
        this.clockIn = clockIn;
        this.paymentType = paymentType;
        this.recordCount = recordCount;
    }

    public PaymentType getPaymentTypeOrDefault() {
        return paymentType != null ? paymentType : PaymentType.TIME;
    }

    public double getRecordCountOrDefault() {
        return recordCount != null ? recordCount : 1.0;
    }

    // 퇴근 처리
    public void clockOut(LocalDateTime clockOut, int hourlyWage) {
        this.clockOut = clockOut;
        this.workMinutes = (int) java.time.Duration.between(this.clockIn, clockOut).toMinutes();
        this.wageAmount = (int) (this.workMinutes / 60.0 * hourlyWage);
    }

    // 사장 수정
    public void modify(LocalDateTime clockIn, LocalDateTime clockOut, int hourlyWage, User modifier) {
        this.clockIn = clockIn;
        this.clockOut = clockOut;
        this.workMinutes = (int) java.time.Duration.between(clockIn, clockOut).toMinutes();
        this.wageAmount = (int) (this.workMinutes / 60.0 * hourlyWage);
        this.isModified = true;
        this.modifiedBy = modifier;
    }
}
