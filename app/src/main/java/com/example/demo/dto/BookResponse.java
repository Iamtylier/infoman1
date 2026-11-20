package com.example.demo.dto;

public record BookResponse(
        Long id,
        String title,
        String author,
        String isbn,
        Long categoryId,
        String category,
        int totalCopies,
        int availableCopies) {
}
