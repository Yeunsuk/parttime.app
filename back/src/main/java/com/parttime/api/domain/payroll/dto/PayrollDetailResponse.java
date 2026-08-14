package com.parttime.api.domain.payroll.dto;

import com.parttime.api.entity.PaymentType;
import com.parttime.api.entity.WorkRecord;
import lombok.Getter;

import java.time.LocalDate;
import java.time.format.DateTimeFormatter;

@Getter
public class PayrollDetailResponse {

    private static final DateTimeFormatter FMT =
        DateTimeFormatter.ofPattern("yyyy-MM-dd'T'HH:mm:ss");

    private final Long id;
    private final Long workerId;
    private final String workerName;
    private final String clockIn;
    private final String clockOut;
    private final Integer workMinutes;
    private final Integer wageAmount;
    private final Boolean isModified;
    private final String paymentType;
    private final double recordCount;
    // "CREATED"(근무생성으로 만들어짐), "MODIFIED"(근무수정으로 바뀜), null(둘 다 아님)
    private final String creationStatus;
    // true면 실제 근무기록이 아니라, 그 날 삭제된 근무기록이 있었다는 것을 알려주는
    // 표시용 placeholder다 (id/clockIn 등은 화면에 쓰지 않는다). 같은 날 다른 근무기록이
    // 남아있어도 그 기록에 태그를 붙이지 않고, 이렇게 별도의 "삭제이력" 항목으로 남긴다.
    private final boolean deletionOnly;

    public PayrollDetailResponse(WorkRecord r) {
        this(r, null);
    }

    public PayrollDetailResponse(WorkRecord r, String creationStatus) {
        this.id = r.getId();
        this.workerId = r.getWorker().getId();
        this.workerName = r.getWorker().getName();
        this.clockIn = r.getClockIn().format(FMT);
        this.clockOut = r.getClockOut() != null ? r.getClockOut().format(FMT) : null;
        this.workMinutes = r.getWorkMinutes();
        this.wageAmount = r.getWageAmount();
        this.isModified = r.getIsModified();
        this.paymentType = r.getPaymentTypeOrDefault().name();
        this.recordCount = r.getRecordCountOrDefault();
        this.creationStatus = creationStatus;
        this.deletionOnly = false;
    }

    private PayrollDetailResponse(Long workerId, String workerName, LocalDate date) {
        this.id = -date.toEpochDay();
        this.workerId = workerId;
        this.workerName = workerName;
        this.clockIn = date.atStartOfDay().format(FMT);
        this.clockOut = null;
        this.workMinutes = 0;
        this.wageAmount = 0;
        this.isModified = false;
        this.paymentType = PaymentType.TIME.name();
        this.recordCount = 0;
        this.creationStatus = null;
        this.deletionOnly = true;
    }

    // 그 날 삭제된 근무기록이 있었다는 사실만 화면에 남기기 위한 placeholder를 만든다.
    // 같은 날 다른(살아남은) 근무기록이 있어도 이 항목은 별도로 함께 추가된다.
    public static PayrollDetailResponse deletionOnlyPlaceholder(
            Long workerId, String workerName, LocalDate date) {
        return new PayrollDetailResponse(workerId, workerName, date);
    }
}
