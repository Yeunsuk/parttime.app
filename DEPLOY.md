# Deploy

`main`에 push하면 GitHub Actions가 이미지를 빌드해 GHCR에 올리고, 서버의 self-hosted runner가 이어받아 배포까지 끝낸다. 서버에서 직접 빌드하는 과정은 없다.

## 흐름

1. `.github/workflows/deploy.yml` `build-and-push` job (GitHub 호스팅 러너)
   - Flutter 웹 빌드 (`front/`, `--dart-define=API_BASE_URL=<secret>`)
   - 빌드 결과를 `back/web-flutter/`에 스테이징
   - Docker 이미지 빌드 (context `./back`) 후 GHCR(`ghcr.io/<owner>/<repo>`, 소문자)로 push
2. `deploy` job (서버의 self-hosted runner, `needs: build-and-push`)
   - `~/parttime.app/deploy-from-registry.sh` 실행 → 새 이미지 pull, 기존 컨테이너 재시작

## 최초 세팅 (서버)

**1. self-hosted runner 등록**

GitHub repo → Settings → Actions → Runners → New self-hosted runner → 화면에 뜨는 안내대로 다운로드/설정. 마지막 실행은 `./run.sh` 대신 서비스로 등록:

```bash
sudo ./svc.sh install
sudo ./svc.sh start
```

**2. 배포 파일 준비** (`~/parttime.app/`)

- `deploy-from-registry.sh` — 이 레포의 `back/deploy-from-registry.sh` 그대로 복사, `chmod +x` 필요
- `.env` — `back/.env`의 키 구조 그대로, 실제 값 채워서 (아래 표 참고)

| 키 | 용도 |
|---|---|
| `DB_PASSWORD`, `JWT_SECRET`, `OWNER_AUTH_CODE` | 앱 런타임 필수 비밀값 |
| `DB_HOST` | DB 컨테이너의 `--network` 내부 호스트명 |
| `IMAGE` | `ghcr.io/<owner>/<repo>:latest` — **owner/repo는 소문자**여야 함 (대문자면 `docker pull`이 `invalid reference format`로 거부) |
| `CONTAINER_NAME`, `NETWORK_NAME`, `HOST_PORT` | `deploy-from-registry.sh`가 컨테이너 실행할 때 쓰는 값 |

**3. GitHub repo secret**

Settings → Secrets and variables → Actions → `API_BASE_URL` 등록. 값은 프론트가 호출할 API 주소, **`/api`로 끝나야 함** (예: `https://<호스트>/api`). 비어있으면 워크플로우가 빌드 전에 실패한다(빈 URL 베이킹 방지).

**4. GHCR 패키지 권한**

repo Settings → Actions → General → Workflow permissions → "Read and write permissions". 그래도 `denied: permission_denied: write_package`가 나면 `github.com/<owner>?tab=packages`에서 해당 패키지 → Package settings → Manage Actions access에 이 repo를 Write로 추가.

## 수동 재배포

서버에서 직접:

```bash
~/parttime.app/deploy-from-registry.sh
```

GitHub Actions 재실행: Actions 탭 → 해당 워크플로우 run → Re-run jobs.
