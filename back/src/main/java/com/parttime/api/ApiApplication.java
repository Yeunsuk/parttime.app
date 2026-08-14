package com.parttime.api;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

import java.util.TimeZone;

@SpringBootApplication
public class ApiApplication {

	public static void main(String[] args) {
		// 컨테이너/서버의 OS 기본 타임존이 UTC일 수 있어(LocalDateTime.now()가 그걸 따라감),
		// 출퇴근 시각이 KST 기준으로 기록되도록 JVM 기본 타임존을 명시적으로 고정한다.
		TimeZone.setDefault(TimeZone.getTimeZone("Asia/Seoul"));
		SpringApplication.run(ApiApplication.class, args);
	}

}
