# API 문서

베이스 URL: `<서버 주소>/api` (배포본은 `back/src/main/resources/application.yml` 기준 포트 8080).

## 공통 규약

- 모든 응답은 `{ "success": boolean, "data": <T|null>, "message": string|null }` 봉투로 감싸진다.
- 인증이 필요한 요청은 `Authorization: Bearer <accessToken>` 헤더가 필요하다. `signup`/`login`/`refresh`만 예외 — 나머지는 전부 401.
- 액세스 토큰이 만료되면 401이 온다. `POST /api/auth/refresh`로 재발급 후 재시도.
- "사장 전용"인 엔드포인트는 해당 근무지(`workplaceId`)의 소유자가 아니면 403(`ACCESS_DENIED`)이 온다.
- 날짜/시각은 별다른 명시가 없으면 `yyyy-MM-dd'T'HH:mm:ss` 문자열.

---

## 인증 (`/api/auth`)

| Method | Path | 인증 | 설명 |
|---|---|---|---|
| POST | `/signup` | 불필요 | 회원가입 |
| POST | `/login` | 불필요 | 로그인 |
| POST | `/refresh` | 불필요 | 리프레시 토큰으로 재발급 |
| GET | `/me` | 필요 | 내 정보 조회 (콜드스타트 세션 복원용) |

**POST /signup**
- 요청: `{ email, password, name, role: "OWNER"|"WORKER", ownerAuthCode }` — `role=OWNER`일 때만 `ownerAuthCode`가 서버의 `OWNER_AUTH_CODE`와 일치해야 함
- 응답: `AuthResponse` — `{ accessToken, refreshToken, user: { id, email, name, role } }`

**POST /login**
- 요청: `{ email, password }`
- 응답: `AuthResponse` (위와 동일). 연속 실패 시 IP 기준 rate limit 걸림.

**POST /refresh**
- 요청: `{ refreshToken }`
- 응답: `AuthResponse`

**GET /me**
- 응답: `UserResponse` — `{ id, email, name, role }`

---

## 근무지·소속 (`/api/workplaces`)

| Method | Path | 인증 | 설명 |
|---|---|---|---|
| POST | `/` | 필요 | 근무지 생성 (사장) |
| POST | `/join` | 필요 | 초대코드로 참가 (근로자) |
| GET | `/my` | 필요 | 내 근무지 목록 |
| GET | `/{workplaceId}/workers` | 사장 전용 | 소속 근로자 목록 |
| PATCH | `/{workplaceId}/member-limit` | 사장 전용 | 인원제한 변경 |
| PATCH | `/{workplaceId}/disabled-hours` | 사장 전용 | 근무기록 시(0~23) 선택지에서 제외할 시간 설정 |
| PATCH | `/{workplaceId}/enabled-minutes` | 사장 전용 | 근무기록 분(0~59) 선택지 설정 (기본 0, 30) |
| POST | `/{workplaceId}/members` | 사장 전용 | 직원 추가 (아이디 없으면 기본 비밀번호로 신규 계정 생성) |
| DELETE | `/{workplaceId}/members/{workerId}` | 사장 전용 | 직원 퇴장 (근무기록은 보존) |
| PATCH | `/{workplaceId}/members/{workerId}/default-time` | 사장 전용 | 직원별 기본 출퇴근 시각 |
| PATCH | `/{workplaceId}/members/{workerId}/pay-period` | 사장 전용 | 직원별 정산 시작일 |
| PATCH | `/{workplaceId}/members/{workerId}/payment-type` | 사장 전용 | 직원별 정산 방식 (`TIME`/`COUNT`) |
| PATCH | `/{workplaceId}/members/{workerId}/working-days` | 사장 전용 | 직원별 요일설정 |

**POST /**
- 요청: `{ name, hourlyWage }`
- 응답: `WorkplaceResponse` — `{ id, name, inviteCode, hourlyWage, ownerName, memberLimit, disabledHours, enabledMinutes }`

**POST /join**
- 요청: `{ inviteCode }` → 응답: `WorkplaceResponse`

**GET /my**
- 응답: `WorkplaceResponse[]`

**GET /{workplaceId}/workers**
- 응답: `WorkerResponse[]` — `{ id, name, defaultClockInHour/Minute, defaultClockOutHour/Minute, payPeriodStartDay, paymentType, workingDaysEnabled, workingDays }`

**PATCH /{workplaceId}/member-limit**
- 요청: `{ memberLimit }` (현재 인원보다 낮게는 불가) → 응답: `WorkplaceResponse`

**PATCH /{workplaceId}/disabled-hours**
- 요청: `{ disabledHours: number[] }` → 응답: `WorkplaceResponse`

**PATCH /{workplaceId}/enabled-minutes**
- 요청: `{ enabledMinutes: number[] }` → 응답: `WorkplaceResponse`

**POST /{workplaceId}/members**
- 요청: `{ email }` → 응답: `WorkerResponse`

**PATCH .../default-time**
- 요청: `{ clockInHour, clockInMinute, clockOutHour, clockOutMinute }` → 응답: `WorkerResponse`

**PATCH .../pay-period**
- 요청: `{ payPeriodStartDay }` (1~28, 1이면 달력월과 동일) → 응답: `WorkerResponse`

**PATCH .../payment-type**
- 요청: `{ paymentType: "TIME"|"COUNT" }` → 응답: `WorkerResponse`

**PATCH .../working-days**
- 요청: `{ enabled, days: number[] }` (1=월 ... 7=일. `enabled=false`면 요일 무관 항상 비활성) → 응답: `WorkerResponse`

---

## 출퇴근 — 근로자 셀프서비스 (`/api/work-records`)

| Method | Path | 설명 |
|---|---|---|
| GET | `/status` | 현재 출근 상태 |
| POST | `/clock-in` | 출근 |
| PATCH | `/{id}/clock-out` | 퇴근 |
| GET | `/calendar?year&month` | 내 월별 근무기록 |

**GET /status**
- 응답: `WorkStatusResponse` — `{ isClockedIn, currentRecord: WorkRecordResponse|null }`

**POST /clock-in**
- 요청: `{ workplaceId }` → 응답: `WorkRecordResponse`

**PATCH /{id}/clock-out**
- 응답: `WorkRecordResponse`. 반올림 결과 근무시간이 30분 미만이면 기록 자체는 남기지 않되 로그는 남는다.

**GET /calendar**
- 응답: `WorkRecordResponse[]` — `{ id, workplaceId, workplaceName, clockIn, clockOut, workMinutes, wageAmount, isModified, creationStatus, deletedSameDay }`

---

## 정산·근무기록 관리 — 사장 전용 (`/api/workplaces/{workplaceId}`, `/api/work-records`)

| Method | Path | 설명 |
|---|---|---|
| GET | `/api/workplaces/{workplaceId}/payroll?year&month` | 근로자별 월간 정산 요약 |
| GET | `/api/workplaces/{workplaceId}/records?year&month` | 근무지 전체 근무기록 (달력용) |
| GET | `/api/workplaces/{workplaceId}/workers/{workerId}/records?year&month` | 근로자별 상세 근무기록 |
| POST | `/api/workplaces/{workplaceId}/workers/{workerId}/records` | 근무기록 추가 |
| PATCH | `/api/work-records/{recordId}/modify` | 근무기록 수정 |
| DELETE | `/api/work-records/{recordId}` | 근무기록 삭제 |
| GET | `/api/workplaces/{workplaceId}/settlement?year&month` | 직원별 정산 (각자 정산기간 기준) |

**GET .../payroll**
- 응답: `PayrollSummaryResponse[]` — `{ workerId, workerName, totalWage, totalMinutes, workDays }`

**GET .../records`, `.../workers/{workerId}/records**
- 응답: `PayrollDetailResponse[]` — `{ id, workerId, workerName, clockIn, clockOut, workMinutes, wageAmount, isModified, paymentType, recordCount, creationStatus: "CREATED"|"MODIFIED", deletionOnly }`. `deletionOnly=true`인 항목은 그 날 삭제된 근무기록이 있었다는 표시용 placeholder.

**POST .../records** (근무기록 추가)
- 요청: `{ clockIn, clockOut, recordCount? }` (횟수제 직원은 `clockOut` 무시, `recordCount` 기본 1) → 응답: `PayrollDetailResponse`

**PATCH /api/work-records/{recordId}/modify**
- 요청: `{ clockIn, clockOut }` → 응답: `PayrollDetailResponse`

**DELETE /api/work-records/{recordId}**
- 응답: `null`

**GET .../settlement**
- 응답: `SettlementResponse[]` — `{ workerId, workerName, periodStart, periodEnd, recordCount, totalMinutes, totalWage, paymentType }`. 현재 소속이 아닌(내보낸) 직원도 그 달에 근무기록이 있으면 포함되며, 이 경우 정산기간은 항상 선택한 달의 1일~마지막일로 계산된다.

---

## 계좌·QR — 사장 전용 (`/api/workplaces/{workplaceId}/accounts`)

| Method | Path | 설명 |
|---|---|---|
| POST | `/` | 계좌 추가 |
| GET | `/` | 계좌 목록 |
| POST | `/{accountId}/qrs` | QR 추가 |
| DELETE | `/{accountId}/qrs/{qrId}` | QR 삭제 |
| DELETE | `/{accountId}` | 계좌 삭제 |

**POST /**
- 요청: `{ accountName, accountNumber, bankName }` → 응답: `AccountResponse` — `{ id, accountName, accountNumber, bankName, qrCodes: AccountQrResponse[] }`

**POST /{accountId}/qrs**
- 요청: `{ name, qrImage }` (`qrImage`는 data URI) → 응답: `AccountResponse`

**DELETE /{accountId}/qrs/{qrId}**, **DELETE /{accountId}**
- 응답: `AccountResponse` / `null`

---

## 에러 응답

실패 시 `{ success: false, data: null, message: "<한국어 메시지>" }`, HTTP 상태코드는 `ErrorCode`([back/src/main/java/com/parttime/api/global/exception/ErrorCode.java](back/src/main/java/com/parttime/api/global/exception/ErrorCode.java))에 정의된 값을 따른다.
