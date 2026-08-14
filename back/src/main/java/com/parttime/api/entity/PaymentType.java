package com.parttime.api.entity;

// 직원의 정산 방식: TIME(시급 × 근무시간), COUNT(근무 1건당 횟수로만 집계, 시간/급여는 계산하지 않음)
public enum PaymentType {
    TIME, COUNT
}
