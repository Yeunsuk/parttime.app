package com.parttime.api.global.security;

import jakarta.servlet.http.HttpServletRequest;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Component;

import java.net.Inet6Address;
import java.net.InetAddress;
import java.net.UnknownHostException;

// Tailscale Funnel처럼 리버스 프록시를 거치면 request.getRemoteAddr()는 실제 클라이언트가
// 아니라 프록시 자신의 주소일 수 있다. X-Forwarded-For(없으면 X-Real-IP)가 채워져 있으면
// 그 값의 첫 번째 주소(왼쪽 끝 = 최초 클라이언트, 그 뒤는 중간 프록시들)를 우선 쓰고,
// 둘 다 없으면 getRemoteAddr()로 돌아간다.
//
// 실제 배포에서 확인된 문제: IPv6 클라이언트는 SLAAC/프라이버시 확장 등으로 같은 기기가
// 시도마다 다른 주소(같은 /64 대역 안에서)를 쓸 수 있어, 128비트 전체를 키로 쓰면 공격자가
// 주소만 바꿔가며 차단을 무한히 우회할 수 있다. IETF 관행상 /64는 보통 가정/기기 하나에
// 통째로 할당되는 최소 단위이므로, IPv6는 앞 64비트(네트워크 prefix)로 묶어서 차단 단위로
// 삼는다 — IPv4는 이런 문제가 없어 그대로 둔다.
@Slf4j
@Component
public class ClientIpResolver {

    public String resolve(HttpServletRequest request) {
        String xForwardedFor = request.getHeader("X-Forwarded-For");
        String resolved;

        if (xForwardedFor != null && !xForwardedFor.isBlank()) {
            resolved = xForwardedFor.split(",")[0].trim();
        } else {
            String xRealIp = request.getHeader("X-Real-IP");
            resolved = (xRealIp != null && !xRealIp.isBlank())
                ? xRealIp.trim()
                : request.getRemoteAddr();
        }

        String normalized = normalizeIfIpv6(resolved);

        log.debug("[LOGIN-RATE-LIMIT] resolved clientIp={} (normalized={}, rawXForwardedFor=\"{}\", remoteAddr={})",
            resolved, normalized, xForwardedFor, request.getRemoteAddr());

        return normalized;
    }

    // IPv6 주소면 앞 64비트(네트워크 prefix)만 남기고 뒤 64비트는 0으로 밀어서 ".../64" 형태의
    // 대표 키로 바꾼다. IPv4거나 파싱에 실패하면(잘못된 헤더 값 등) 원본 문자열을 그대로 쓴다.
    private String normalizeIfIpv6(String ip) {
        try {
            InetAddress addr = InetAddress.getByName(ip);
            if (!(addr instanceof Inet6Address)) {
                return ip;
            }
            byte[] full = addr.getAddress();
            byte[] prefixOnly = new byte[16];
            System.arraycopy(full, 0, prefixOnly, 0, 8);
            return InetAddress.getByAddress(prefixOnly).getHostAddress() + "/64";
        } catch (UnknownHostException e) {
            return ip;
        }
    }
}
