package com.example.demo.repository;

import com.example.demo.entity.Loan;
import java.util.List;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;

public interface LoanRepository extends JpaRepository<Loan, Long> {

    boolean existsByBookId(Long bookId);

    boolean existsByMemberId(Long memberId);

    @Query("select l from Loan l join fetch l.book join fetch l.member order by l.id")
    List<Loan> findAllWithDetails();
}
