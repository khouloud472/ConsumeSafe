package com.consumesafe.service;

import com.consumesafe.entity.Product;
import com.consumesafe.repository.ProductRepository;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class ProductService {

    private final ProductRepository productRepository;

    public ProductService(ProductRepository productRepository) {
        this.productRepository = productRepository;
    }

    public boolean isBoycotted(String productName) {
        return productRepository.findByBoycottedTrue()
                .stream()
                .anyMatch(p -> p.getName().equalsIgnoreCase(productName));
    }

    public List<Product> getTunisianAlternatives() {
        return productRepository.findByTunisianTrue();
    }
}
