package com.parttime.api.domain.workplace.dto;

import jakarta.validation.constraints.Max;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotNull;
import lombok.Getter;

@Getter
public class UpdateDefaultTimeRequest {

    // -1은 "현재시간"(고정값이 아니라 실제 사용 시점의 현재시각으로 채워짐)을 의미하는 특수값이다.
    @NotNull
    @Min(-1) @Max(23)
    private Integer clockInHour;

    @NotNull
    @Min(0) @Max(59)
    private Integer clockInMinute;

    // -1은 "현재시간"을 의미하는 특수값이다.
    @NotNull
    @Min(-1) @Max(23)
    private Integer clockOutHour;

    @NotNull
    @Min(0) @Max(59)
    private Integer clockOutMinute;
}
