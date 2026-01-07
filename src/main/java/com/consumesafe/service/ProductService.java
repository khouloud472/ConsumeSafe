// Fichier: src/main/java/com/consumesafe/service/ProductService.java
package com.consumesafe.service;

import com.consumesafe.entity.Product;
import com.consumesafe.repository.ProductRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Optional;

@Slf4j
@Service
@Transactional(readOnly = true)
@RequiredArgsConstructor
public class ProductService {
    
    private final ProductRepository productRepository;
    
    public Optional<Product> findByName(String productName) {
        return productRepository.findByNameIgnoreCase(productName);
    }
    
    public boolean isBoycotted(String productName) {
        Optional<Product> product = productRepository.findByNameIgnoreCase(productName);
        return product.map(Product::getBoycotted).orElse(false);
    }
    
    public String getBoycottReason(String productName) {
        return productRepository.findByNameIgnoreCase(productName)
                .map(Product::getBoycottReason)
                .orElse(null);
    }
    
    public List<Product> getTunisianAlternatives() {
        return productRepository.findByTunisianTrue();
    }
    
    public List<Product> getTunisianAlternativesByCategory(String category) {
        return productRepository.findByCategoryAndTunisianTrue(category);
    }
    
    public List<Product> getBoycottedProducts() {
        return productRepository.findByBoycottedTrue();
    }
    
    public List<Product> searchProducts(String query) {
        return productRepository.findByNameContainingIgnoreCaseOrDescriptionContainingIgnoreCase(query, query);
    }
    
    @Transactional
    public Product saveProduct(Product product) {
        log.info("Saving product: {}", product.getName());
        return productRepository.save(product);
    }
    
    @Transactional
    public void deleteProduct(Long id) {
        productRepository.deleteById(id);
        log.info("Deleted product with id: {}", id);
    }
    
    public List<Product> getAllProducts() {
        return productRepository.findAll();
    }
    
    public Optional<Product> getProductById(Long id) {
        return productRepository.findById(id);
    }
    
    public boolean productExists(String name) {
        return productRepository.existsByName(name);
    }
}