# parttime API

알바 출퇴근/급여 관리 앱의 백엔드. Spring Boot 4.1.0, Java 21, Gradle(Kotlin DSL).

## 빌드 & 실행

```bash
./gradlew build          # 전체 빌드 (Windows: gradlew.bat build)
./gradlew bootRun         # 서버 실행 (포트 8080)
./gradlew test             # 전체 테스트
```

로컬 PostgreSQL이 필요합니다 (`src/main/resources/application.yml` 기준: db `parttime`, user/password `parttime`/`parttime1234`, port `5432`). `spring.jpa.hibernate.ddl-auto=update`라 엔티티 클래스만 추가/수정하면 스키마가 자동으로 반영됩니다 — 별도 마이그레이션 스크립트가 없습니다.

## 의존성 목록 (`build.gradle.kts`)

| 의존성 | 용도 |
|---|---|
| `spring-boot-starter-web` | REST API (내장 Tomcat, MVC) |
| `spring-boot-starter-data-jpa` | JPA/Hibernate ORM |
| `spring-boot-starter-security` | 인증/인가 프레임워크 (JWT 필터를 여기에 등록) |
| `spring-boot-starter-validation` | `@Valid` 요청 바디 검증 |
| `io.jsonwebtoken:jjwt-api/-impl/-jackson` | JWT 발급/검증 (access/refresh 토큰) |
| `org.postgresql:postgresql` | PostgreSQL JDBC 드라이버 |
| `org.projectlombok:lombok` | `@Getter`/`@Builder`/`@RequiredArgsConstructor` 등 보일러플레이트 제거 |
| `spring-boot-starter-test` (test) | JUnit5, Mockito 등 테스트 스택 |
| `spring-security-test` (test) | Security 관련 테스트 유틸 |

## 패키지 구조

`domain.<feature>` 단위로 나뉘어 있고, 각 도메인은 `controller/`, `service/`, `repository/`, `dto/` 서브패키지를 가집니다. JPA 엔티티는 도메인에 속하지 않고 `entity` 패키지에 flat하게 모아둡니다. 인증/예외/JWT/공통응답 같은 횡단 관심사는 `global`에 있습니다.

### `ApiApplication.java`
Spring Boot 진입점. `main()`에서 JVM 기본 타임존을 `Asia/Seoul`로 고정한 뒤 앱을 실행합니다 — 컨테이너의 OS 기본 타임존이 UTC일 수 있어(`LocalDateTime.now()`가 그걸 따라감), 출퇴근 시각이 한국 시간 기준으로 기록되도록 하기 위함입니다.

### `domain/auth` — 회원가입/로그인/세션
근로지에 속하기 전, 계정 자체(사장/근로자)를 다루는 도메인.

- `controller/AuthController.java` — 회원가입/로그인/토큰갱신/내 정보 조회 엔드포인트
- `service/AuthService.java` — 회원가입(사장으로 가입 시 인증코드 검증 포함), 로그인, 리프레시 토큰으로 재발급, 내 정보 조회. JWT 발급도 여기서 처리
- `repository/UserRepository.java` — 이메일(로그인 ID) 기준 조회/중복 확인
- `dto/LoginRequest.java` — 로그인 요청 바디 (email, password)
- `dto/SignupRequest.java` — 회원가입 요청 바디 (email, password, name, role, 사장 인증코드)
- `dto/RefreshTokenRequest.java` — 토큰 재발급 요청 바디
- `dto/UserResponse.java` — User 엔티티 → 클라이언트용 응답 (id/email/name/role)
- `dto/AuthResponse.java` — 로그인/회원가입/갱신 성공 응답 (access/refresh 토큰 + 사용자 정보)

### `domain/workplace` — 근무지·소속 관리
근무지 생성/참가, 사장-근로자 소속관계, 인원제한, 직원 추가/퇴장을 다루는 도메인. 이 폴더는 "누가 어느 근무지에 속해있는가"에 대한 관리를 담당합니다.

- `controller/WorkplaceController.java` — 근무지 생성/초대코드 참가/내 근무지 목록/소속 근로자 목록/인원제한 변경/직원 추가·퇴장 엔드포인트
- `service/WorkplaceService.java` — 근무지 생성, 초대코드로 참가(인원제한 초과 시 거부), 인원제한 변경(현재 인원보다 낮게는 불가), 직원 추가(아이디가 없으면 기본 비밀번호로 신규 계정까지 생성) 및 퇴장(소속만 해제, 근무기록은 보존) 로직
- `repository/WorkplaceRepository.java` — 초대코드 기반 조회/존재 확인
- `repository/WorkplaceMemberRepository.java` — 근무지-근로자 소속관계 조회(이름순 정렬)/카운트
- `dto/CreateWorkplaceRequest.java` — 근무지 생성 요청 (이름, 시급)
- `dto/JoinWorkplaceRequest.java` — 초대코드 참가 요청
- `dto/AddMemberRequest.java` — 사장이 아이디로 직원을 추가할 때의 요청
- `dto/UpdateMemberLimitRequest.java` — 인원제한 변경 요청
- `dto/WorkerResponse.java` — 근로자를 근무지 소속원 목록용으로 간단 변환 (id/name)
- `dto/WorkplaceResponse.java` — Workplace → 클라이언트 응답 (초대코드/시급/사장이름/인원제한 포함)

### `domain/workrecord` — 출퇴근(근로자 셀프서비스)
근로자 본인이 직접 찍는 출근/퇴근을 다루는 도메인. "지금 이 순간의 내 출퇴근"이 관심사입니다.

- `controller/WorkRecordController.java` — 출근상태 조회/출근/퇴근/내 달력 조회 엔드포인트
- `service/WorkRecordService.java` — 출근(중복 출근 방지, 30분 단위 반올림), 퇴근(반올림 결과 30분 미만이면 기록 자체를 남기지 않되 로그는 남김), 월별 달력 조회. 출퇴근마다 `WorkLogService`로 활동 로그도 남김
- `repository/WorkRecordRepository.java` — 현재 출근중인 기록 조회, 근로자/근무지별 기간 조회
- `dto/ClockInRequest.java` — 출근 요청 (workplaceId)
- `dto/WorkRecordResponse.java` — WorkRecord → 근로자용 응답 (근무지명/출퇴근시각/근무시간/급여)
- `dto/WorkStatusResponse.java` — 현재 출근 여부 + 진행 중인 근무기록

### `domain/payroll` — 사장 입장의 근무기록/급여 조회·관리
사장이 근로자들의 근무기록을 조회하고, 필요하면 직접 추가/수정/삭제하는 도메인. `entity`/`repository`가 따로 없고 `WorkRecordRepository`/`WorkplaceRepository`를 그대로 가져다 씁니다. 이 폴더는 근무지의 총 근무 내역(전체 근로자) 및 근로자별 상세 내역에 대한 조회·관리를 담당합니다.

- `controller/PayrollController.java` — 월별 정산요약/전체근무기록/근로자별 상세기록 조회, 근무기록 수정·추가·삭제 엔드포인트 (전부 사장 전용)
- `service/PayrollService.java` — 근로자별 월간 정산 요약 계산, 근무지 전체/근로자별 근무기록 조회, 근무기록 수정·추가·삭제. 추가/수정/삭제할 때마다 `WorkLogService`로 활동 로그(변경 전/후 시각 포함)를 남김
- `dto/PayrollSummaryResponse.java` — 근로자별 월간 요약 (총 급여/총 근무분/근무일수) — 지금은 프론트에서 안 쓰지만 범용 리포트용으로 남겨둠
- `dto/PayrollDetailResponse.java` — WorkRecord → 사장용 상세 응답 (근로자 정보 포함, 전체/개인 달력 공용)
- `dto/ModifyRecordRequest.java` — 근무기록 수정/추가 시 새 출퇴근 시각 (수정과 추가 둘 다 이 DTO를 재사용)

### `domain/worklog` — 활동 로그(감사 이력)
출퇴근/근무기록 추가·수정·삭제가 "언제, 누가, 무엇을" 했는지 지우지 않고 쌓아두는 도메인. `WorkRecordService`/`PayrollService`가 이벤트 발생 시마다 호출하는 방식이라, 이 도메인 자체는 다른 도메인 로직을 모릅니다.

- `repository/WorkLogRepository.java` — 근무지별 로그를 최신순으로 조회
- `service/WorkLogService.java` — 로그 한 건을 저장하는 헬퍼 (다른 서비스에서 주입받아 호출)

### `entity` — JPA 엔티티 (도메인 무관, flat)

- `User.java` — 계정 (email=로그인 ID, password=해시, name, role: OWNER/WORKER)
- `Workplace.java` — 근무지 (owner, name, inviteCode, hourlyWage, memberLimit — null이면 `getMemberLimitOrDefault()`로 7 취급)
- `WorkplaceMember.java` — 근무지-근로자 소속관계 (조인 엔티티)
- `WorkRecord.java` — 출퇴근 기록. `clockOut()`(퇴근 처리)과 `modify()`(사장 수정/추가 겸용) 도메인 메서드를 가짐 — 급여는 항상 이 두 메서드 안에서 시급×근무시간으로 계산됨
- `WorkLog.java` — 활동 로그. `workRecordId`는 FK로 강하게 묶지 않은 참조값이라, 원본 `WorkRecord`가 삭제돼도(예: 30분 미만 근무) 로그는 그대로 남음

### `global/config`

- `JpaConfig.java` — `@EnableJpaAuditing` (엔티티의 `@CreatedDate` 자동 채움 활성화)
- `SecurityConfig.java` — Security 설정: CSRF 비활성화, CORS 전체 허용(Bearer 토큰 기반이라 쿠키 CSRF 리스크 없음), 세션 무상태(stateless), `JwtFilter` 등록, `signup`/`login`/`refresh`만 인증 예외(그 외 `/api/**`는 전부 인증 필요), 웹앱 정적 리소스 경로는 인증 없이 허용

### `global/exception`

- `BusinessException.java` — `ErrorCode`를 담아 던지는 비즈니스 예외 (도메인 서비스에서 이것만 던지면 됨)
- `ErrorCode.java` — 에러 상황별 (HTTP 상태, 한국어 메시지) 열거형 — 새 에러 케이스는 여기 추가
- `GlobalExceptionHandler.java` — `BusinessException`/미처리 예외를 잡아 공통 `ApiResponse` 실패 형식으로 변환

### `global/jwt`

- `JwtProperties.java` — `application.yml`의 `jwt.*` 프로퍼티(시크릿, 만료시간) 바인딩
- `JwtProvider.java` — access/refresh 토큰 발급·검증, 클레임(userId/role/type) 추출
- `JwtFilter.java` — `Authorization: Bearer` 헤더의 access 토큰을 검증해 `SecurityContextHolder`에 인증 정보(principal=userId) 세팅. refresh 토큰은 여기서 거부됨

### `global/response`

- `ApiResponse.java` — 모든 컨트롤러 응답을 `{success, data, message}` 형태로 감싸는 공통 래퍼. 컨트롤러는 이걸로 감싸서 반환하고, 프론트(Dio 인터셉터)는 이 봉투를 한 곳에서 벗겨냄
