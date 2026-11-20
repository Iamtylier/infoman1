package com.example.demo.controller;

import com.example.demo.dto.LoanResponse;
import com.example.demo.service.BorrowService;
import java.util.List;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/loans")
public class LoanController {

    private final BorrowService borrowService;

    public LoanController(BorrowService borrowService) {
        this.borrowService = borrowService;
    }

    @GetMapping
    public List<LoanResponse> findAll() {
        return borrowService.findAll();
    }

    @PostMapping
    public ResponseEntity<LoanResponse> borrow(@RequestParam Long bookId,
                                               @RequestParam Long memberId,
                                               @RequestParam(defaultValue = "false") boolean simulateFailure) {
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(borrowService.borrow(bookId, memberId, simulateFailure));
    }
}
