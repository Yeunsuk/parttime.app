# parttime 프론트

알바 출퇴근/급여 관리 앱의 Flutter 프론트엔드. web/Android/iOS/desktop 전부 이 소스 하나로 빌드된다.

## 빌드 & 실행

```bash
flutter pub get
flutter run                        # 로컬 개발 (기본 API_BASE_URL: http://localhost:8080/api)
flutter analyze                    # 린트
flutter test                       # 전체 테스트
dart run build_runner build --delete-conflicting-outputs   # 코드젠
```

`@riverpod`, `freezed`, `@JsonSerializable`가 붙은 클래스를 건드리면 반드시 코드젠을 다시 돌려야 한다 (`*.g.dart`/`*.freezed.dart`는 직접 수정하지 말 것).

실제 서버를 대상으로 로컬에서 테스트하려면:

```bash
flutter run --dart-define=API_BASE_URL=https://<서버 주소>/api
```

## 구조 (feature-first)

`lib/features/<feature>/`가 기본 단위이고, 각 feature는 세 계층으로 나뉜다.

- `data/` — `*_api.dart` (Dio로 실제 HTTP 호출) → `*_repository.dart` (`DioException`을 `AppException`으로 번역)
- `domain/` — `freezed`/`json_serializable` 모델
- `presentation/` — `@riverpod` 노티파이어 + 화면

| feature | 내용 |
|---|---|
| `auth` | 로그인/회원가입, 세션 상태 (`AuthState`는 콜드스타트 시 `GET /api/auth/me`로 복원) |
| `workplace` | 근무지 생성/참가, 소속 관리, "지금 선택된 근무지"(`WorkplaceGate`) |
| `work_record` | 근로자 본인의 출퇴근 찍기/달력 |
| `payroll` | 사장 화면 — 근무지 전체 달력(`OwnerHomeScreen`), 근로자별 상세(`WorkerDetailScreen`), 정산(`SettlementScreen`) |
| `account` | 계좌/QR 관리, 공개 계좌 팝업 (`account_popup`, 로그인 없이 접근 가능) |

`core/`에 횡단 관심사가 있다.

- `core/network/dio_client.dart` — 단일 Dio 인스턴스. 인터셉터가 `{success,data,message}` 응답 봉투를 여기서 한 번만 벗긴다 — 다른 곳에서 또 벗기지 말 것. 401이 오면 refresh 토큰으로 재발급 후 재시도 (동시에 여러 요청이 401나도 refresh는 한 번만 수행).
- `core/router/app_router.dart` — 단일 `@riverpod` `GoRouter`, `redirect`가 `authStateProvider` 기준으로 역할(OWNER/WORKER)별 라우팅.
- `core/constants/api_constants.dart` — `baseUrl`은 `--dart-define=API_BASE_URL`로 주입 (CI에서는 GitHub secret, 로컬은 기본값 `http://localhost:8080/api`).
- `core/storage/secure_storage.dart` — 토큰 저장.

## 주요 동작 메모

- 워크플레이스 ID는 절대 하드코딩하지 않는다 — 항상 `WorkplaceGate`/`myWorkplacesProvider`로 해석.
- 정산 화면(`settlement_screen.dart`)은 시간제 직원이 그 달 정산액 0원이면 목록에서 생략한다. 횟수제는 0회여도 표시.
- 사장 홈 화면 달력(`owner_home_screen.dart`)은 날짜를 선택하면 바로 그 주만 남기고 축소되고, 선택을 해제하면 월 단위로 되돌아간다.
- 정산 PNG 캡처는 웹에서만 지원 (`dart:html` 기반 다운로드, `png_download_web.dart`/`_stub.dart`로 분기).

API 엔드포인트 전체 목록은 저장소 루트의 [API.md](../API.md) 참고.
