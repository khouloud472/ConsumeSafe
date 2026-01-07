package com.consumesafe.repository;

import com.consumesafe.entity.Product;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface ProductRepository extends JpaRepository<Product, Long> {
    List<Product> findByBoycottedTrue();
    List<Product> findByTunisianTrue();
    Optional<Product> findByName(String name);
    Optional<Product> findByNameIgnoreCase(String name);
    Optional<Product> findByBarcode(String barcode);
    List<Product> findByCategoryAndTunisianTrue(String category);
    List<Product> findByNameContainingIgnoreCaseOrDescriptionContainingIgnoreCase(String name, String description);
    boolean existsByName(String name);
}
