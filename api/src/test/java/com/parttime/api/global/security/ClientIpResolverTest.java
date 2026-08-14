package com.parttime.api.global.security;

import org.junit.jupiter.api.Test;
import org.springframework.mock.web.MockHttpServletRequest;

import static org.assertj.core.api.Assertions.assertThat;

// IPv6 클라이언트가 SLAAC/프라이버시 확장 등으로 시도마다 같은 /64 대역 안에서 다른 주소를
// 써도 rate limit이 같은 키로 묶이는지 검증한다 (실배포에서 IPv4/IPv6로 각각 별도로 5회씩
// 차단을 우회할 수 있었던 문제의 수정 검증).
class ClientIpResolverTest {

    private final ClientIpResolver resolver = new ClientIpResolver();

    private String resolveFromXff(String xForwardedFor) {
        MockHttpServletRequest request = new MockHttpServletRequest();
        request.addHeader("X-Forwarded-For", xForwardedFor);
        return resolver.resolve(request);
    }

    @Test
    void 같은_64비트_대역의_서로_다른_IPv6_주소는_같은_키로_묶인다() {
        String a = resolveFromXff("2001:2d8:763b:236e:71ff:60ae:69b3:45f7");
        String b = resolveFromXff("2001:2d8:763b:236e:aaaa:bbbb:cccc:dddd");

        assertThat(a).isEqualTo(b);
        assertThat(a).isEqualTo("2001:2d8:763b:236e:0:0:0:0/64");
    }

    @Test
    void 다른_64비트_대역의_IPv6_주소는_다른_키가_된다() {
        String a = resolveFromXff("2001:2d8:763b:236e:71ff:60ae:69b3:45f7");
        String b = resolveFromXff("2001:2d8:763b:9999:71ff:60ae:69b3:45f7");

        assertThat(a).isNotEqualTo(b);
    }

    @Test
    void IPv4_주소는_그대로_사용된다() {
        assertThat(resolveFromXff("211.186.162.79")).isEqualTo("211.186.162.79");
    }

    @Test
    void XFF에_여러_주소가_있으면_첫번째만_사용한다() {
        assertThat(resolveFromXff("211.186.162.79, 100.64.0.1, 10.0.0.1"))
            .isEqualTo("211.186.162.79");
    }
}
