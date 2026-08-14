package com.parttime.api.global.exception;

import lombok.Getter;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;

@Getter
@RequiredArgsConstructor
public enum ErrorCode {
    INVALID_CREDENTIALS(HttpStatus.UNAUTHORIZED, "이메일 또는 비밀번호가 올바르지 않습니다."),
    INVALID_REFRESH_TOKEN(HttpStatus.UNAUTHORIZED, "리프레시 토큰이 유효하지 않습니다. 다시 로그인해주세요."),
    DUPLICATE_EMAIL(HttpStatus.CONFLICT, "이미 사용 중인 이메일입니다."),
    USER_NOT_FOUND(HttpStatus.NOT_FOUND, "사용자를 찾을 수 없습니다."),
    WORKPLACE_NOT_FOUND(HttpStatus.NOT_FOUND, "근무지를 찾을 수 없습니다."),
    INVALID_INVITE_CODE(HttpStatus.BAD_REQUEST, "유효하지 않은 초대코드입니다."),
    ALREADY_CLOCKED_IN(HttpStatus.CONFLICT, "이미 출근 중입니다."),
    NOT_CLOCKED_IN(HttpStatus.BAD_REQUEST, "출근 기록이 없습니다."),
    RECORD_NOT_FOUND(HttpStatus.NOT_FOUND, "근무기록을 찾을 수 없습니다."),
    ACCESS_DENIED(HttpStatus.FORBIDDEN, "권한이 없습니다."),
    WORKPLACE_MEMBER_LIMIT_EXCEEDED(HttpStatus.CONFLICT, "근무지 인원이 가득 찼습니다."),
    INVALID_OWNER_AUTH_CODE(HttpStatus.BAD_REQUEST, "사장 인증코드가 올바르지 않습니다."),
    CANNOT_ADD_OWNER_AS_WORKER(HttpStatus.BAD_REQUEST, "사장 계정은 근로자로 추가할 수 없습니다."),
    WORKPLACE_MEMBER_NOT_FOUND(HttpStatus.NOT_FOUND, "해당 근로자가 이 근무지 소속이 아닙니다."),
    MEMBER_LIMIT_BELOW_CURRENT_COUNT(HttpStatus.BAD_REQUEST, "현재 인원보다 적은 수로 설정할 수 없습니다."),
    ACCOUNT_NOT_FOUND(HttpStatus.NOT_FOUND, "계좌를 찾을 수 없습니다."),
    ACCOUNT_QR_NOT_FOUND(HttpStatus.NOT_FOUND, "QR을 찾을 수 없습니다.");

    private final HttpStatus status;
    private final String message;
}
