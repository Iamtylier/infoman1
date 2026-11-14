package com.example.demo.repository;

import com.example.demo.entity.Book;
import java.util.List;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;

public interface BookRepository extends JpaRepository<Book, Long> {

    // join fetch loads the category in the same query, so lazy loading is not needed later
    @Query("select b from Book b join fetch b.category order by b.id")
    List<Book> findAllWithCategory();
}
