package com.parttime.api.domain.workplace.repository;

import com.parttime.api.entity.Workplace;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface WorkplaceRepository extends JpaRepository<Workplace, Long> {
    Optional<Workplace> findByInviteCode(String inviteCode);
    boolean existsByInviteCode(String inviteCode);
}
