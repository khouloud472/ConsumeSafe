// Fichier: src/main/java/com/consumesafe/controller/ProductController.java
package com.consumesafe.controller;

import com.consumesafe.entity.Product;
import com.consumesafe.repository.ProductRepository;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/products")
public class ProductController {
    
    private final ProductRepository productRepository;
    
    public ProductController(ProductRepository productRepository) {
        this.productRepository = productRepository;
    }
    
    @GetMapping("/check/{productName}")
    public boolean isBoycotted(@PathVariable String productName) {
        return productRepository.findByBoycottedTrue()
                .stream()
                .anyMatch(p -> p.getName().equalsIgnoreCase(productName));
    }
    
    @GetMapping("/alternatives")
    public List<Product> getTunisianAlternatives() {
        return productRepository.findByTunisianTrue();
    }
}