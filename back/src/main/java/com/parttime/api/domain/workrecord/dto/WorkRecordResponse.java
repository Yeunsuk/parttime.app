package com.parttime.api.domain.workrecord.dto;

import com.parttime.api.entity.WorkRecord;
import lombok.Getter;

import java.time.format.DateTimeFormatter;

@Getter
public class WorkRecordResponse {

    private static final DateTimeFormatter FMT =
        DateTimeFormatter.ofPattern("yyyy-MM-dd'T'HH:mm:ss");

    private final Long id;
    private final Long workplaceId;
    private final String workplaceName;
    private final String clockIn;
    private final String clockOut;
    private final Integer workMinutes;
    private final Integer wageAmount;
    private final Boolean isModified;
    // "CREATED"(근무생성으로 만들어짐), "MODIFIED"(근무수정으로 바뀜), null(둘 다 아님)
    private final String creationStatus;
    // 이 기록이 속한 날짜에 삭제된 기록이 있었는지 (이 기록 자체가 아니라 "그 날")
    private final Boolean deletedSameDay;

    public WorkRecordResponse(WorkRecord r) {
        this(r, null, false);
    }

    public WorkRecordResponse(WorkRecord r, String creationStatus, boolean deletedSameDay) {
        this.id = r.getId();
        this.workplaceId = r.getWorkplace().getId();
        this.workplaceName = r.getWorkplace().getName();
        this.clockIn = r.getClockIn().format(FMT);
        this.clockOut = r.getClockOut() != null ? r.getClockOut().format(FMT) : null;
        this.workMinutes = r.getWorkMinutes();
        this.wageAmount = r.getWageAmount();
        this.isModified = r.getIsModified();
        this.creationStatus = creationStatus;
        this.deletedSameDay = deletedSameDay;
    }
}
