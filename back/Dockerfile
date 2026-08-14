FROM eclipse-temurin:21-jdk AS build
# web-html 사용 시 config.js의 __API_BASE_URL__ 자리표시자를 이 값으로 치환한다
# (실제 호스트명을 레포에 남기지 않기 위함). CI에서는 secrets.API_BASE_URL로 전달.
ARG API_BASE_URL=
WORKDIR /app
COPY gradlew ./
COPY gradle ./gradle
COPY build.gradle.kts settings.gradle.kts ./
RUN ./gradlew --no-daemon dependencies || true
COPY src ./src
# 프론트 두 종류 중 서버에 실제로 배포할 쪽 한 줄만 살리고 나머지는 주석 처리한다.
# - web-flutter: Flutter web 소스(front/)는 별도 빌드 단계(CI 또는 build-web-for-api.sh)에서
#   미리 빌드해서 web-flutter/에 넣어둔 결과물을 그대로 정적 리소스로 복사한다. 그래서
#   백엔드만 고칠 때는 이 스테이지에 Flutter SDK가 전혀 관여하지 않아 재배포가 빠르다.
# - web-html: 빌드 단계 없는 순수 HTML/CSS/JS 버전(web-html/, 별도 빌드 스크립트 불필요).
COPY web-flutter ./src/main/resources/static
# COPY web-html ./src/main/resources/static
# web-html을 쓸 때만 해당: config.js의 자리표시자를 실제 주소로 치환한다.
# web-flutter를 쓸 때는 해당 파일이 없어 조건문에서 조용히 건너뛴다.
RUN if [ -n "$API_BASE_URL" ] && [ -f ./src/main/resources/static/js/config.js ]; then \
      sed -i "s#__API_BASE_URL__#${API_BASE_URL}#g" ./src/main/resources/static/js/config.js; \
    fi
RUN chmod +x ./gradlew
RUN ./gradlew --no-daemon bootJar -x test

FROM eclipse-temurin:21-jre
WORKDIR /app
COPY --from=build /app/build/libs/*.jar app.jar
EXPOSE 8080
ENTRYPOINT ["java", "-jar", "app.jar"]
