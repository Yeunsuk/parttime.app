package com.parttime.api.domain.payroll.service;

import com.parttime.api.domain.auth.repository.UserRepository;
import com.parttime.api.domain.payroll.dto.ModifyRecordRequest;
import com.parttime.api.domain.payroll.dto.PayrollDetailResponse;
import com.parttime.api.domain.payroll.dto.PayrollSummaryResponse;
import com.parttime.api.domain.payroll.dto.SettlementResponse;
import com.parttime.api.domain.worklog.repository.WorkLogRepository;
import com.parttime.api.domain.worklog.service.WorkLogService;
import com.parttime.api.domain.workrecord.repository.WorkRecordRepository;
import com.parttime.api.domain.workplace.repository.WorkplaceMemberRepository;
import com.parttime.api.domain.workplace.repository.WorkplaceRepository;
import com.parttime.api.entity.PaymentType;
import com.parttime.api.entity.User;
import com.parttime.api.entity.WorkLog;
import com.parttime.api.entity.WorkRecord;
import com.parttime.api.entity.Workplace;
import com.parttime.api.entity.WorkplaceMember;
import com.parttime.api.global.exception.BusinessException;
import com.parttime.api.global.exception.ErrorCode;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.YearMonth;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class PayrollService {

    // 사장이 수정할 때 입력하는 시각은 초 단위가 없으므로(시/분만 선택) :ss 없이 파싱한다.
    private static final DateTimeFormatter FMT =
        DateTimeFormatter.ofPattern("yyyy-MM-dd'T'HH:mm");
    private static final DateTimeFormatter LOG_TIME_FMT = DateTimeFormatter.ofPattern("HH:mm");

    private final WorkRecordRepository workRecordRepository;
    private final WorkplaceRepository workplaceRepository;
    private final WorkplaceMemberRepository workplaceMemberRepository;
    private final UserRepository userRepository;
    private final WorkLogService workLogService;
    private final WorkLogRepository workLogRepository;

    // 근무지 월별 정산 요약 (사장)
    @Transactional(readOnly = true)
    public List<PayrollSummaryResponse> getPayrollSummary(
            Long ownerId, Long workplaceId, int year, int month) {

        validateOwner(ownerId, workplaceId);

        YearMonth ym = YearMonth.of(year, month);
        LocalDateTime start = ym.atDay(1).atStartOfDay();
        LocalDateTime end = ym.atEndOfMonth().atTime(23, 59, 59);

        List<WorkRecord> records = workRecordRepository
            .findByWorkplaceIdAndClockInBetween(workplaceId, start, end);

        // 근로자별 그룹핑
        Map<Long, List<WorkRecord>> grouped = records.stream()
            .filter(r -> r.getClockOut() != null)
            .collect(Collectors.groupingBy(r -> r.getWorker().getId()));

        return grouped.entrySet().stream().map(entry -> {
            Long workerId = entry.getKey();
            List<WorkRecord> workerRecords = entry.getValue();

            String workerName = workerRecords.get(0).getWorker().getName();
            int totalWage = workerRecords.stream()
                .mapToInt(r -> r.getWageAmount() != null ? r.getWageAmount() : 0)
                .sum();
            int totalMinutes = workerRecords.stream()
                .mapToInt(r -> r.getWorkMinutes() != null ? r.getWorkMinutes() : 0)
                .sum();
            int workDays = (int) workerRecords.stream()
                .map(r -> r.getClockIn().toLocalDate())
                .distinct()
                .count();

            return new PayrollSummaryResponse(
                workerId, workerName, totalWage, totalMinutes, workDays);
        }).toList();
    }

    // 근무지 전체 근로자 근무기록 조회 (달력용, 사장)
    @Transactional(readOnly = true)
    public List<PayrollDetailResponse> getWorkplaceRecords(
            Long ownerId, Long workplaceId, int year, int month) {

        validateOwner(ownerId, workplaceId);

        YearMonth ym = YearMonth.of(year, month);
        LocalDateTime start = ym.atDay(1).atStartOfDay();
        LocalDateTime end = ym.atEndOfMonth().atTime(23, 59, 59);

        List<WorkRecord> records = workRecordRepository
            .findByWorkplaceIdAndClockInBetween(workplaceId, start, end)
            .stream()
            .filter(r -> r.getClockOut() != null)
            .toList();

        return buildDetailResponses(records, loadModifiedRecordIds(records));
    }

    // 근로자 상세 근무기록 조회 (사장). 그 날 삭제된 근무기록이 있으면(다른 근무기록이
    // 남아있는지와 무관하게) "삭제이력"이라는 표시용 placeholder를 하나 추가해서 돌려준다 —
    // 남아있는 다른 근무기록에는 삭제 관련 태그를 붙이지 않는다.
    @Transactional(readOnly = true)
    public List<PayrollDetailResponse> getWorkerDetail(
            Long ownerId, Long workplaceId, Long workerId, int year, int month) {

        validateOwner(ownerId, workplaceId);

        YearMonth ym = YearMonth.of(year, month);
        LocalDateTime start = ym.atDay(1).atStartOfDay();
        LocalDateTime end = ym.atEndOfMonth().atTime(23, 59, 59);

        List<WorkRecord> records = workRecordRepository
            .findByWorkplaceIdAndWorkerIdAndClockInBetween(workplaceId, workerId, start, end);

        List<PayrollDetailResponse> responses =
            new ArrayList<>(buildDetailResponses(records, loadModifiedRecordIds(records)));

        Set<LocalDate> deletedDates = workLogRepository
            .findByWorkerIdAndActionAndRecordDateBetween(
                workerId, WorkLog.Action.RECORD_DELETED, ym.atDay(1), ym.atEndOfMonth())
            .stream()
            .map(WorkLog::getRecordDate)
            .collect(Collectors.toSet());

        if (!deletedDates.isEmpty()) {
            User worker = userRepository.findById(workerId)
                .orElseThrow(() -> new BusinessException(ErrorCode.USER_NOT_FOUND));
            for (LocalDate d : deletedDates) {
                responses.add(PayrollDetailResponse.deletionOnlyPlaceholder(
                    workerId, worker.getName(), d));
            }
        }

        return responses;
    }

    // 이 기록들 중 "근무수정" 버튼으로 실제 수정된 적이 있는 기록의 id 집합.
    // 근무기록 추가(addRecord)도 내부적으로 modify()를 재사용해 isModified가 항상
    // true가 되므로, isModified만으로는 "근무생성"과 "근무수정"을 구분할 수 없어
    // RECORD_MODIFIED 로그가 실제로 남았는지를 따로 확인한다. 이 로그가 없으면(사장이
    // 근무생성으로 만들었든, 직원이 직접 출퇴근을 찍었든) "생성됨"으로 취급한다.
    private Set<Long> loadModifiedRecordIds(List<WorkRecord> records) {
        List<Long> recordIds = records.stream().map(WorkRecord::getId).toList();
        if (recordIds.isEmpty()) return Set.of();
        return workLogRepository
            .findByWorkRecordIdInAndActionIn(recordIds, List.of(WorkLog.Action.RECORD_MODIFIED))
            .stream()
            .map(WorkLog::getWorkRecordId)
            .collect(Collectors.toSet());
    }

    private List<PayrollDetailResponse> buildDetailResponses(
            List<WorkRecord> records, Set<Long> modifiedRecordIds) {

        return records.stream()
            .map(r -> {
                String creationStatus =
                    modifiedRecordIds.contains(r.getId()) ? "MODIFIED" : "CREATED";
                return new PayrollDetailResponse(r, creationStatus);
            })
            .toList();
    }

    // 근무기록 수정 (사장)
    @Transactional
    public PayrollDetailResponse modifyRecord(
            Long ownerId, Long recordId, ModifyRecordRequest req) {

        WorkRecord record = workRecordRepository.findById(recordId)
            .orElseThrow(() -> new BusinessException(ErrorCode.RECORD_NOT_FOUND));

        // 해당 근무지의 사장인지 확인
        validateOwner(ownerId, record.getWorkplace().getId());

        User modifier = userRepository.findById(ownerId)
            .orElseThrow(() -> new BusinessException(ErrorCode.USER_NOT_FOUND));

        String beforeText = record.getClockIn().format(LOG_TIME_FMT) + "~"
            + (record.getClockOut() != null ? record.getClockOut().format(LOG_TIME_FMT) : "?");

        LocalDateTime newClockIn = LocalDateTime.parse(req.getClockIn(), FMT);
        LocalDateTime newClockOut = LocalDateTime.parse(req.getClockOut(), FMT);
        int hourlyWage = record.getWorkplace().getHourlyWage();

        record.modify(newClockIn, newClockOut, hourlyWage, modifier);

        String afterText = newClockIn.format(LOG_TIME_FMT) + "~" + newClockOut.format(LOG_TIME_FMT);
        workLogService.log(record.getWorkplace(), record.getWorker(), modifier, record.getId(),
            newClockIn.toLocalDate(), WorkLog.Action.RECORD_MODIFIED,
            "근무기록 수정 (" + beforeText + " → " + afterText + ")");

        return new PayrollDetailResponse(record);
    }

    // 근무기록 추가 (사장이 근로자의 근무시간을 새로 등록)
    @Transactional
    public PayrollDetailResponse addRecord(
            Long ownerId, Long workplaceId, Long workerId, ModifyRecordRequest req) {

        Workplace workplace = validateOwner(ownerId, workplaceId);

        WorkplaceMember member = workplaceMemberRepository
            .findByWorkplaceIdAndWorkerId(workplaceId, workerId)
            .orElseThrow(() -> new BusinessException(ErrorCode.ACCESS_DENIED));

        User worker = userRepository.findById(workerId)
            .orElseThrow(() -> new BusinessException(ErrorCode.USER_NOT_FOUND));
        User owner = userRepository.findById(ownerId)
            .orElseThrow(() -> new BusinessException(ErrorCode.USER_NOT_FOUND));

        PaymentType paymentType = member.getPaymentTypeOrDefault();
        LocalDateTime clockIn = LocalDateTime.parse(req.getClockIn(), FMT);
        // 횟수제 직원은 출퇴근 시각을 입력받지 않으므로, 클라이언트가 보낸 clockOut과 무관하게
        // clockIn과 동일하게 고정해 근무시간/급여가 항상 0으로 계산되게 한다.
        LocalDateTime clockOut = paymentType == PaymentType.COUNT
            ? clockIn : LocalDateTime.parse(req.getClockOut(), FMT);
        int hourlyWage = workplace.getHourlyWage();

        // 횟수제는 요청에 담긴 횟수(1 또는 0.5)를, 미전달이면 1회를 기본으로 사용한다.
        Double recordCount = paymentType == PaymentType.COUNT
            ? (req.getRecordCount() != null ? req.getRecordCount() : 1.0)
            : null;

        WorkRecord record = WorkRecord.builder()
            .workplace(workplace)
            .worker(worker)
            .clockIn(clockIn)
            .paymentType(paymentType)
            .recordCount(recordCount)
            .build();
        // 사장이 직접 등록한 기록도 "수정됨" 표시와 같은 의미로 modify()를 재사용해
        // clockOut/근무시간/급여를 계산하고 등록자(modifiedBy)를 남긴다.
        record.modify(clockIn, clockOut, hourlyWage, owner);

        workRecordRepository.save(record);

        workLogService.log(workplace, worker, owner, record.getId(),
            clockIn.toLocalDate(), WorkLog.Action.RECORD_ADDED,
            "근무기록 추가 (" + clockIn.format(LOG_TIME_FMT) + "~" + clockOut.format(LOG_TIME_FMT) + ")");

        return new PayrollDetailResponse(record);
    }

    // 근무기록 삭제 (사장)
    @Transactional
    public void deleteRecord(Long ownerId, Long recordId) {
        WorkRecord record = workRecordRepository.findById(recordId)
            .orElseThrow(() -> new BusinessException(ErrorCode.RECORD_NOT_FOUND));

        validateOwner(ownerId, record.getWorkplace().getId());

        User remover = userRepository.findById(ownerId)
            .orElseThrow(() -> new BusinessException(ErrorCode.USER_NOT_FOUND));

        String timeText = record.getClockIn().format(LOG_TIME_FMT) + "~"
            + (record.getClockOut() != null ? record.getClockOut().format(LOG_TIME_FMT) : "?");
        workLogService.log(record.getWorkplace(), record.getWorker(), remover, record.getId(),
            record.getClockIn().toLocalDate(), WorkLog.Action.RECORD_DELETED,
            "근무기록 삭제 (" + timeText + ")");

        workRecordRepository.delete(record);
    }

    // 근무지 소속 직원별 정산 (사장 전용). 각 직원이 설정한 정산기간(월급설정, 없으면 달력월)
    // 중 선택된 (year, month)에 해당하는 기간을 기준으로 근무기록을 집계한다.
    @Transactional(readOnly = true)
    public List<SettlementResponse> getSettlement(
            Long ownerId, Long workplaceId, int year, int month) {
        validateOwner(ownerId, workplaceId);

        // 이름순으로 가져온 뒤 정산방식(시간제 먼저) 기준으로 다시 정렬한다 —
        // sorted()는 안정 정렬이라 같은 정산방식 안에서는 기존 이름순이 그대로 유지된다.
        List<WorkplaceMember> members = workplaceMemberRepository
            .findByWorkplaceIdOrderByWorkerNameAsc(workplaceId)
            .stream()
            .sorted(Comparator.comparingInt(
                m -> m.getPaymentTypeOrDefault() == PaymentType.COUNT ? 1 : 0))
            .toList();
        YearMonth selectedMonth = YearMonth.of(year, month);

        return members.stream().map(member -> {
            int startDay = member.getPayPeriodStartDay() != null ? member.getPayPeriodStartDay() : 1;
            LocalDate periodStart = resolvePeriodStart(selectedMonth, startDay);
            LocalDate periodEnd = periodStart.plusMonths(1).minusDays(1);

            List<WorkRecord> records = workRecordRepository
                .findByWorkplaceIdAndWorkerIdAndClockInBetween(
                    workplaceId, member.getWorker().getId(),
                    periodStart.atStartOfDay(), periodEnd.atTime(23, 59, 59))
                .stream()
                .filter(r -> r.getClockOut() != null)
                .toList();

            int totalMinutes = records.stream()
                .mapToInt(r -> r.getWorkMinutes() != null ? r.getWorkMinutes() : 0).sum();
            int totalWage = records.stream()
                .mapToInt(r -> r.getWageAmount() != null ? r.getWageAmount() : 0).sum();
            double totalCount = records.stream()
                .mapToDouble(WorkRecord::getRecordCountOrDefault).sum();

            return new SettlementResponse(
                member.getWorker().getId(),
                member.getWorker().getName(),
                periodStart.toString(),
                periodEnd.toString(),
                totalCount,
                totalMinutes,
                totalWage,
                member.getPaymentTypeOrDefault().name());
        }).toList();
    }

    // startDay가 속한, 선택된 (year,month)에 대응하는 정산 기간의 시작일을 구한다.
    // 정산기간은 매번 두 달에 걸치므로(예: 6일 시작이면 이번달 6일~다음달 5일), 그 기간의
    // 날짜 수가 더 많이 포함된 달을 기준으로 그 기간을 귀속시킨다.
    // 예: startDay=6, 선택된 달=7월(31일)이면 "7월6일~8월5일"(7월분 26일 > 8월분 5일) 기간이
    // 7월 정산으로 표시된다 — "6월6일~7월5일"(7월분 5일뿐)이 아니다.
    private LocalDate resolvePeriodStart(YearMonth selectedMonth, int startDay) {
        if (startDay <= 1) {
            return selectedMonth.atDay(1);
        }
        int daysInSelectedMonth = selectedMonth.lengthOfMonth();
        int portionIfStartsInSelectedMonth = daysInSelectedMonth - startDay + 1;
        int portionIfStartsInPrevMonth = startDay - 1;

        if (portionIfStartsInSelectedMonth >= portionIfStartsInPrevMonth) {
            return selectedMonth.atDay(Math.min(startDay, daysInSelectedMonth));
        }
        YearMonth prevMonth = selectedMonth.minusMonths(1);
        return prevMonth.atDay(Math.min(startDay, prevMonth.lengthOfMonth()));
    }

    // 사장 권한 검증
    private Workplace validateOwner(Long ownerId, Long workplaceId) {
        Workplace workplace = workplaceRepository.findById(workplaceId)
            .orElseThrow(() -> new BusinessException(ErrorCode.WORKPLACE_NOT_FOUND));

        if (!workplace.getOwner().getId().equals(ownerId)) {
            throw new BusinessException(ErrorCode.ACCESS_DENIED);
        }
        return workplace;
    }
}
