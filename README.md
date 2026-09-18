# parttime

알바생 출퇴근·급여 정산 관리 앱. 사장은 근무지를 만들어 직원을 초대하고 근무기록/정산을 관리하고, 근로자는 앱에서 직접 출퇴근을 찍는다.

## 구성

모노레포. 백엔드와 프론트가 하나의 배포 이미지로 합쳐진다 (프론트 정적 파일을 백엔드가 서빙).

| 디렉터리 | 내용 | 문서 |
|---|---|---|
| `back/` | Spring Boot 백엔드 (Java 21, Gradle Kotlin DSL) | [back/README.md](back/README.md) |
| `front/` | Flutter 프론트 (web/Android/iOS/desktop) | [front/README.md](front/README.md) |

API 전체 목록은 [API.md](API.md), 배포 파이프라인(GitHub Actions → GHCR → self-hosted runner)은 [DEPLOY.md](DEPLOY.md) 참고.

## 빠른 시작 (로컬 개발)

```bash
# 백엔드 (로컬 PostgreSQL 필요 — back/README.md 참고)
cd back && ./gradlew bootRun

# 프론트
cd front && flutter pub get && flutter run
```

## 기술 스택

- **백엔드**: Spring Boot, Spring Security(JWT, stateless), Spring Data JPA, PostgreSQL
- **프론트**: Flutter, Riverpod(코드젠), go_router, Dio, freezed
- **배포**: GitHub Actions → Docker 이미지 빌드 → GHCR → self-hosted runner가 서버에서 pull/재기동

## License

[MIT](LICENSE)
