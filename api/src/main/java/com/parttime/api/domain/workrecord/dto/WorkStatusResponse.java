package com.parttime.api.domain.workrecord.dto;

import lombok.Getter;

@Getter
public class WorkStatusResponse {

    // Lombok+Jackson이 primitive boolean getter(isXxx())의 "is"를 벗겨서
    // JSON 키가 "clockedIn"이 돼버리는 것을 피하려고 Boolean으로 박싱해서 쓴다.
    // (WorkRecordResponse.isModified와 동일한 패턴)
    private final Boolean isClockedIn;
    private final WorkRecordResponse currentRecord;

    public WorkStatusResponse(Boolean isClockedIn, WorkRecordResponse currentRecord) {
        this.isClockedIn = isClockedIn;
        this.currentRecord = currentRecord;
    }
}
