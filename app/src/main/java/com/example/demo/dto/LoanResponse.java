package com.example.demo.dto;

public record LoanResponse(
        Long id,
        Long bookId,
        String bookTitle,
        Long memberId,
        String memberName,
        String loanedOn,
        String dueOn,
        String returnedOn) {
}
