package com.parttime.api.entity;

import jakarta.persistence.*;
import lombok.*;
import org.springframework.data.annotation.CreatedDate;
import org.springframework.data.jpa.domain.support.AuditingEntityListener;

import java.time.LocalDateTime;
import java.util.HashSet;
import java.util.Set;

@Entity
@Table(name = "workplace_members",
    uniqueConstraints = @UniqueConstraint(columnNames = {"workplace_id", "worker_id"}))
@Getter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
@EntityListeners(AuditingEntityListener.class)
public class WorkplaceMember {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "workplace_id", nullable = false)
    private Workplace workplace;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "worker_id", nullable = false)
    private User worker;

    @CreatedDate
    private LocalDateTime joinedAt;

    // 이 직원 전용 기본 출퇴근 시간 (근무기록 추가 다이얼로그의 초기값으로 쓰임).
    // null이면 프론트가 쓰는 전역 기본값(18시~22시)을 그대로 쓴다.
    private Integer defaultClockInHour;
    private Integer defaultClockInMinute;
    private Integer defaultClockOutHour;
    private Integer defaultClockOutMinute;

    // 이 직원의 정산 기간 시작일 (예: 6이면 "매월 6일 ~ 다음달 5일"). null이면 달력월(1일 시작)로 취급한다.
    private Integer payPeriodStartDay;

    // 정산 방식 (시간제/횟수제). null이면 기존 직원 전부와 동일하게 TIME으로 취급한다.
    @Enumerated(EnumType.STRING)
    private PaymentType paymentType;

    // 요일설정: "미설정"(workingDaysEnabled=false/null)이면 요일 제한 없이 항상 활성으로
    // 취급한다. true면 workingDays(1=월요일 ... 7=일요일, java.time.DayOfWeek.getValue()와
    // 동일한 값)에 포함된 요일에만 활성 — 근무기록 추가 다이얼로그의 근로자 정렬 우선순위에 쓰인다.
    private Boolean workingDaysEnabled;

    @ElementCollection(fetch = FetchType.EAGER)
    @CollectionTable(name = "workplace_member_working_days", joinColumns = @JoinColumn(name = "workplace_member_id"))
    @Column(name = "day_of_week")
    private Set<Integer> workingDays = new HashSet<>();

    @Builder
    public WorkplaceMember(Workplace workplace, User worker) {
        this.workplace = workplace;
        this.worker = worker;
    }

    public void changeDefaultTime(Integer clockInHour, Integer clockInMinute,
                                   Integer clockOutHour, Integer clockOutMinute) {
        this.defaultClockInHour = clockInHour;
        this.defaultClockInMinute = clockInMinute;
        this.defaultClockOutHour = clockOutHour;
        this.defaultClockOutMinute = clockOutMinute;
    }

    public void changePayPeriodStartDay(Integer payPeriodStartDay) {
        this.payPeriodStartDay = payPeriodStartDay;
    }

    public PaymentType getPaymentTypeOrDefault() {
        return paymentType != null ? paymentType : PaymentType.TIME;
    }

    public void changePaymentType(PaymentType paymentType) {
        this.paymentType = paymentType;
    }

    public boolean getWorkingDaysEnabledOrDefault() {
        return workingDaysEnabled != null && workingDaysEnabled;
    }

    // dayOfWeekValue: java.time.DayOfWeek.getValue() (1=월요일 ... 7=일요일)
    // "미설정"(workingDaysEnabled=false)이면 선택된 요일 자체가 없으므로 항상 비활성이다.
    public boolean isActiveOnDay(int dayOfWeekValue) {
        return getWorkingDaysEnabledOrDefault() && workingDays.contains(dayOfWeekValue);
    }

    public void changeWorkingDays(Boolean enabled, Set<Integer> days) {
        this.workingDaysEnabled = enabled;
        this.workingDays = days != null ? days : new HashSet<>();
    }
}
