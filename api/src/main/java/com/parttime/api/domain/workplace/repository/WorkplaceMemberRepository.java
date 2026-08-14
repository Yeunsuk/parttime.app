package com.parttime.api.domain.workplace.repository;

import com.parttime.api.entity.WorkplaceMember;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;

public interface WorkplaceMemberRepository extends JpaRepository<WorkplaceMember, Long> {
    List<WorkplaceMember> findByWorkerId(Long workerId);
    List<WorkplaceMember> findByWorkplaceIdOrderByWorkerNameAsc(Long workplaceId);
    boolean existsByWorkplaceIdAndWorkerId(Long workplaceId, Long workerId);
    Optional<WorkplaceMember> findByWorkplaceIdAndWorkerId(Long workplaceId, Long workerId);
    long countByWorkplaceId(Long workplaceId);
}
