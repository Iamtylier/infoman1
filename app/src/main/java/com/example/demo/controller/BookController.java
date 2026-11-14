package com.example.demo.controller;

import com.example.demo.dto.BookResponse;
import com.example.demo.repository.BookRepository;
import java.util.List;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/books")
public class BookController {

    private final BookRepository bookRepository;

    public BookController(BookRepository bookRepository) {
        this.bookRepository = bookRepository;
    }

    @GetMapping
    public List<BookResponse> findAll() {
        return bookRepository.findAllWithCategory().stream()
                .map(b -> new BookResponse(
                        b.getId(),
                        b.getTitle(),
                        b.getAuthor(),
                        b.getIsbn(),
                        b.getCategory().getName(),
                        b.getTotalCopies(),
                        b.getAvailableCopies()))
                .toList();
    }
}
