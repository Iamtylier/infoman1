package com.example.demo.service;

import com.example.demo.dto.BookRequest;
import com.example.demo.dto.BookResponse;
import com.example.demo.entity.Book;
import com.example.demo.entity.Category;
import com.example.demo.exception.BadRequestException;
import com.example.demo.exception.ConflictException;
import com.example.demo.exception.NotFoundException;
import com.example.demo.repository.BookRepository;
import com.example.demo.repository.CategoryRepository;
import com.example.demo.repository.LoanRepository;
import java.util.List;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class BookService {

    private final BookRepository bookRepository;
    private final CategoryRepository categoryRepository;
    private final LoanRepository loanRepository;

    public BookService(BookRepository bookRepository,
                       CategoryRepository categoryRepository,
                       LoanRepository loanRepository) {
        this.bookRepository = bookRepository;
        this.categoryRepository = categoryRepository;
        this.loanRepository = loanRepository;
    }

    @Transactional(readOnly = true)
    public List<BookResponse> findAll() {
        return bookRepository.findAllWithCategory().stream().map(this::toResponse).toList();
    }

    @Transactional(readOnly = true)
    public BookResponse findById(Long id) {
        Book book = bookRepository.findByIdWithCategory(id)
                .orElseThrow(() -> new NotFoundException("Book " + id + " was not found."));
        return toResponse(book);
    }

    @Transactional
    public BookResponse create(BookRequest request) {
        validate(request);
        String isbn = request.isbn().trim();
        if (bookRepository.existsByIsbn(isbn)) {
            throw new ConflictException("A book with ISBN " + isbn + " already exists.");
        }
        Category category = findCategory(request.categoryId());
        int total = request.totalCopies();
        Book book = new Book(category, request.title().trim(), request.author().trim(), isbn, total, total);
        return toResponse(bookRepository.saveAndFlush(book));
    }

    @Transactional
    public BookResponse update(Long id, BookRequest request) {
        Book book = bookRepository.findById(id)
                .orElseThrow(() -> new NotFoundException("Book " + id + " was not found."));
        validate(request);
        String isbn = request.isbn().trim();
        if (bookRepository.existsByIsbnAndIdNot(isbn, id)) {
            throw new ConflictException("Another book already uses ISBN " + isbn + ".");
        }
        Category category = findCategory(request.categoryId());

        // Keep the invariant: copies currently on loan stay on loan.
        int onLoan = book.getTotalCopies() - book.getAvailableCopies();
        int newTotal = request.totalCopies();
        if (newTotal < onLoan) {
            throw new BadRequestException("Total copies cannot be less than the " + onLoan
                    + " copies currently on loan.");
        }
        book.setCategory(category);
        book.setTitle(request.title().trim());
        book.setAuthor(request.author().trim());
        book.setIsbn(isbn);
        book.setTotalCopies(newTotal);
        book.setAvailableCopies(newTotal - onLoan);
        return toResponse(bookRepository.saveAndFlush(book));
    }

    // Delete rule: a book that has loan records is history, so it is never deleted.
    @Transactional
    public void delete(Long id) {
        if (!bookRepository.existsById(id)) {
            throw new NotFoundException("Book " + id + " was not found.");
        }
        if (loanRepository.existsByBookId(id)) {
            throw new ConflictException("Book " + id + " has loan records and cannot be deleted.");
        }
        bookRepository.deleteById(id);
    }

    private Category findCategory(Long categoryId) {
        return categoryRepository.findById(categoryId)
                .orElseThrow(() -> new BadRequestException("Category " + categoryId + " does not exist."));
    }

    private void validate(BookRequest r) {
        if (r == null) {
            throw new BadRequestException("The request body is required.");
        }
        if (r.categoryId() == null) {
            throw new BadRequestException("Category is required.");
        }
        if (r.title() == null || r.title().isBlank() || r.title().trim().length() > 150) {
            throw new BadRequestException("Title is required (up to 150 characters).");
        }
        if (r.author() == null || r.author().isBlank() || r.author().trim().length() > 100) {
            throw new BadRequestException("Author is required (up to 100 characters).");
        }
        if (r.isbn() == null || r.isbn().isBlank() || r.isbn().trim().length() > 20) {
            throw new BadRequestException("ISBN is required (up to 20 characters).");
        }
        if (r.totalCopies() == null || r.totalCopies() < 0) {
            throw new BadRequestException("Total copies is required and cannot be negative.");
        }
    }

    private BookResponse toResponse(Book b) {
        return new BookResponse(
                b.getId(),
                b.getTitle(),
                b.getAuthor(),
                b.getIsbn(),
                b.getCategory().getId(),
                b.getCategory().getName(),
                b.getTotalCopies(),
                b.getAvailableCopies());
    }
}
