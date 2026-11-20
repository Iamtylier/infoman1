package com.example.demo.dto;

public record BookRequest(
        Long categoryId,
        String title,
        String author,
        String isbn,
        Integer totalCopies) {
}
