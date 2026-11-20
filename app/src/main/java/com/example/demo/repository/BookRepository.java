package com.example.demo.repository;

import com.example.demo.entity.Book;
import java.util.List;
import java.util.Optional;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

public interface BookRepository extends JpaRepository<Book, Long> {

    @Query("select b from Book b join fetch b.category order by b.id")
    List<Book> findAllWithCategory();

    @Query("select b from Book b join fetch b.category where b.id = :id")
    Optional<Book> findByIdWithCategory(@Param("id") Long id);

    boolean existsByIsbn(String isbn);

    boolean existsByIsbnAndIdNot(String isbn, Long id);

    // Atomic conditional update: the database decides, in one statement, whether a copy is free.
    // Returns 1 if a copy was taken, 0 if none were available.
    @Modifying
    @Query("update Book b set b.availableCopies = b.availableCopies - 1 "
            + "where b.id = :id and b.availableCopies > 0")
    int decrementAvailable(@Param("id") Long id);
}
