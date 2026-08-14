#!/bin/bash
# git pull + 서버 빌드 대신, CI(GHCR)가 미리 빌드해둔 이미지를 pull만 해서 띄운다.
# 컨테이너명/네트워크명/포트/이미지 경로까지 전부 .env로 뺐다 — 이 스크립트 자체엔
# 식별 가능한 값이 남지 않는다. .env는 서버에만 존재 (.env.example 참고, git 미추적).
set -euo pipefail
cd "$(dirname "$0")"
set -a
source .env
set +a

docker pull "$IMAGE"
docker stop "$CONTAINER_NAME" || true
docker rm "$CONTAINER_NAME" || true
docker run -d \
  --name "$CONTAINER_NAME" \
  --network "$NETWORK_NAME" \
  -p "${HOST_PORT}:8080" \
  --env-file .env \
  --restart unless-stopped \
  "$IMAGE"

echo "배포 완료: $IMAGE"
