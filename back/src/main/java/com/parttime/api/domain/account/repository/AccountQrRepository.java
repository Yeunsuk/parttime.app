package com.parttime.api.domain.account.repository;

import com.parttime.api.entity.AccountQr;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;

public interface AccountQrRepository extends JpaRepository<AccountQr, Long> {
    List<AccountQr> findByAccountIdOrderByIdAsc(Long accountId);
    Optional<AccountQr> findByIdAndAccountId(Long id, Long accountId);
    void deleteByAccountId(Long accountId);
}
