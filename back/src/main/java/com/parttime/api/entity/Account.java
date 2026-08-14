package com.parttime.api.entity;

import jakarta.persistence.*;
import lombok.*;

@Entity
@Table(name = "accounts")
@Getter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
public class Account {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "workplace_id", nullable = false)
    private Workplace workplace;

    @Column(nullable = false)
    private String accountName;

    @Column(nullable = false)
    private String accountNumber;

    @Column(nullable = false)
    private String bankName;

    @Builder
    public Account(Workplace workplace, String accountName, String accountNumber, String bankName) {
        this.workplace = workplace;
        this.accountName = accountName;
        this.accountNumber = accountNumber;
        this.bankName = bankName;
    }
}
