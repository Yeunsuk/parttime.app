package com.parttime.api.domain.payroll.dto;

import jakarta.validation.constraints.NotBlank;
import lombok.Getter;

@Getter
public class ModifyRecordRequest {

    @NotBlank
    private String clockIn;  // "yyyy-MM-dd'T'HH:mm:ss"

    @NotBlank
    private String clockOut;

    // 횟수제(COUNT) 직원 근무기록 추가 시에만 사용 (1 또는 0.5). 미전달/시간제면 무시되고 1회로 취급된다.
    private Double recordCount;
}
