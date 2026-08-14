package com.parttime.api.domain.workplace.dto;

import jakarta.validation.constraints.Max;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotNull;
import lombok.Getter;

@Getter
public class UpdatePayPeriodRequest {

    // 1이면 달력월(1일~말일). 그 외(2~28)면 "매월 N일 ~ 다음달 (N-1)일"로 정산한다.
    @NotNull
    @Min(1) @Max(28)
    private Integer payPeriodStartDay;
}
