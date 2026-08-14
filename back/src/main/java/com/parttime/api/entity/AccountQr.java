package com.parttime.api.entity;

import jakarta.persistence.*;
import lombok.*;

// 계좌 1개에 여러 QR을 등록할 수 있다 — 은행/간편결제 앱마다 QR 규격이 달라
// 이름을 붙여 구분해야 하므로.
@Entity
@Table(name = "account_qrs")
@Getter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
public class AccountQr {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "account_id", nullable = false)
    private Account account;

    @Column(nullable = false)
    private String name;

    // "data:image/png;base64,..." 형태의 data URI를 그대로 저장한다 — 별도 파일
    // 스토리지 없이 DB 한 곳에서 관리하기 위함(QR 이미지 용량이 크지 않아 문제 없음).
    @Lob
    @Column(columnDefinition = "TEXT", nullable = false)
    private String qrImage;

    @Builder
    public AccountQr(Account account, String name, String qrImage) {
        this.account = account;
        this.name = name;
        this.qrImage = qrImage;
    }
}
