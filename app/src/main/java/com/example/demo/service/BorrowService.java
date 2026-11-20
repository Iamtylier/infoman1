package com.example.demo.service;

import com.example.demo.dto.LoanResponse;
import com.example.demo.entity.Book;
import com.example.demo.entity.Loan;
import com.example.demo.entity.Member;
import com.example.demo.exception.ConflictException;
import com.example.demo.exception.NotFoundException;
import com.example.demo.exception.SimulatedFailureException;
import com.example.demo.repository.BookRepository;
import com.example.demo.repository.LoanRepository;
import com.example.demo.repository.MemberRepository;
import java.time.LocalDate;
import java.util.List;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class BorrowService {

    private static final int LOAN_DAYS = 14;

    private final BookRepository bookRepository;
    private final MemberRepository memberRepository;
    private final LoanRepository loanRepository;

    public BorrowService(BookRepository bookRepository,
                         MemberRepository memberRepository,
                         LoanRepository loanRepository) {
        this.bookRepository = bookRepository;
        this.memberRepository = memberRepository;
        this.loanRepository = loanRepository;
    }

    /**
     * Borrow a book. Two records change together: the book's available_copies goes down by one,
     * and a loan row is inserted. Both happen inside ONE transaction, so either both are saved
     * or neither is. A RuntimeException leaving this method triggers a rollback.
     *
     * Invariant: available_copies never becomes negative, and every decrement has a loan.
     *
     * The decrement is a conditional UPDATE (... WHERE available_copies > 0). The database applies it
     * atomically, so two people borrowing the last copy at the same time cannot both succeed.
     *
     * simulateFailure is a demo hook: it throws AFTER both writes, to prove that the rollback
     * undoes them. Remove or lock it down before the final release.
     */
    @Transactional
    public LoanResponse borrow(Long bookId, Long memberId, boolean simulateFailure) {
        Book book = bookRepository.findById(bookId)
                .orElseThrow(() -> new NotFoundException("Book " + bookId + " was not found."));
        Member member = memberRepository.findById(memberId)
                .orElseThrow(() -> new NotFoundException("Member " + memberId + " was not found."));

        int changed = bookRepository.decrementAvailable(bookId);
        if (changed != 1) {
            throw new ConflictException("No copies of \"" + book.getTitle() + "\" are available.");
        }

        LocalDate today = LocalDate.now();
        Loan loan = loanRepository.saveAndFlush(new Loan(book, member, today, today.plusDays(LOAN_DAYS)));

        if (simulateFailure) {
            throw new SimulatedFailureException(
                    "Simulated failure after both writes. The transaction was rolled back.");
        }
        return toResponse(loan);
    }

    @Transactional(readOnly = true)
    public List<LoanResponse> findAll() {
        return loanRepository.findAllWithDetails().stream().map(this::toResponse).toList();
    }

    private LoanResponse toResponse(Loan l) {
        return new LoanResponse(
                l.getId(),
                l.getBook().getId(),
                l.getBook().getTitle(),
                l.getMember().getId(),
                l.getMember().getFullName(),
                l.getLoanedOn().toString(),
                l.getDueOn().toString(),
                l.getReturnedOn() == null ? null : l.getReturnedOn().toString());
    }
}
