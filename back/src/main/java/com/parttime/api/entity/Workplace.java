package com.parttime.api.entity;

import jakarta.persistence.*;
import lombok.*;
import org.springframework.data.annotation.CreatedDate;
import org.springframework.data.jpa.domain.support.AuditingEntityListener;

import java.time.LocalDateTime;
import java.util.HashSet;
import java.util.Set;

@Entity
@Table(name = "workplaces")
@Getter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
@EntityListeners(AuditingEntityListener.class)
public class Workplace {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "owner_id", nullable = false)
    private User owner;

    @Column(nullable = false)
    private String name;

    @Column(nullable = false, unique = true, length = 10)
    private String inviteCode;

    @Column(nullable = false)
    private Integer hourlyWage;

    // 기존에 만들어진 근무지는 DB엔 이 컬럼이 null일 수 있어서(마이그레이션 안전을 위해
    // nullable로 둠), 읽는 쪽(WorkplaceResponse/가입 검증)에서 null이면 기본값 7로 취급한다.
    private Integer memberLimit;

    // 근무지 전체에 적용되는, 근무기록 생성/수정 시 시(0~23) 목록에서 제외할 시간대.
    // 새 근무지는 빈 집합으로 시작(전부 표시)하므로 별도의 OrDefault 처리가 필요 없다.
    @ElementCollection(fetch = FetchType.EAGER)
    @CollectionTable(name = "workplace_disabled_hours", joinColumns = @JoinColumn(name = "workplace_id"))
    @Column(name = "hour")
    private Set<Integer> disabledHours = new HashSet<>();

    // 근무기록 생성/수정 시 분(0~59) 목록에 표시할, 활성화된 분 목록(화이트리스트).
    // 시(disabledHours)와 달리 기본값이 "전부 표시"가 아니라 "0, 30분만 표시"이므로
    // 빈 집합(=미설정)일 때는 getEnabledMinutesOrDefault()에서 {0, 30}으로 취급한다.
    @ElementCollection(fetch = FetchType.EAGER)
    @CollectionTable(name = "workplace_enabled_minutes", joinColumns = @JoinColumn(name = "workplace_id"))
    @Column(name = "minute")
    private Set<Integer> enabledMinutes = new HashSet<>();

    @CreatedDate
    private LocalDateTime createdAt;

    private static final Set<Integer> DEFAULT_ENABLED_MINUTES = Set.of(0, 30);

    @Builder
    public Workplace(User owner, String name, String inviteCode, Integer hourlyWage) {
        this.owner = owner;
        this.name = name;
        this.inviteCode = inviteCode;
        this.hourlyWage = hourlyWage;
        this.memberLimit = DEFAULT_MEMBER_LIMIT;
    }

    public static final int DEFAULT_MEMBER_LIMIT = 7;

    public int getMemberLimitOrDefault() {
        return memberLimit != null ? memberLimit : DEFAULT_MEMBER_LIMIT;
    }

    // 사장이 인원제한을 변경
    public void changeMemberLimit(int memberLimit) {
        this.memberLimit = memberLimit;
    }

    // 사장이 근무지 시간설정(비활성화할 시간대)을 변경
    public void changeDisabledHours(Set<Integer> disabledHours) {
        this.disabledHours = disabledHours;
    }

    public Set<Integer> getEnabledMinutesOrDefault() {
        return (enabledMinutes == null || enabledMinutes.isEmpty())
            ? DEFAULT_ENABLED_MINUTES : enabledMinutes;
    }

    // 사장이 근무지 분설정(활성화할 분 목록)을 변경
    public void changeEnabledMinutes(Set<Integer> enabledMinutes) {
        this.enabledMinutes = enabledMinutes;
    }
}
