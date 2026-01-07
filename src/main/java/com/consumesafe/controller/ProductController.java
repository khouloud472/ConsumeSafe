// Fichier: src/main/java/com/consumesafe/controller/ProductController.java
package com.consumesafe.controller;

import com.consumesafe.entity.Product;
import com.consumesafe.service.ProductService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/products")
@RequiredArgsConstructor
public class ProductController {
    
    private final ProductService productService;
    
    @GetMapping("/check/{productName}")
    public ResponseEntity<Boolean> isBoycotted(@PathVariable String productName) {
        boolean isBoycotted = productService.isBoycotted(productName);
        return ResponseEntity.ok(isBoycotted);
    }
    
    @GetMapping("/alternatives")
    public ResponseEntity<List<Product>> getTunisianAlternatives() {
        List<Product> alternatives = productService.getTunisianAlternatives();
        return ResponseEntity.ok(alternatives);
    }
    
    @GetMapping("/alternatives/{category}")
    public ResponseEntity<List<Product>> getTunisianAlternativesByCategory(@PathVariable String category) {
        List<Product> alternatives = productService.getTunisianAlternativesByCategory(category);
        return ResponseEntity.ok(alternatives);
    }
    
    @GetMapping("/boycotted")
    public ResponseEntity<List<Product>> getBoycottedProducts() {
        List<Product> boycottedProducts = productService.getBoycottedProducts();
        return ResponseEntity.ok(boycottedProducts);
    }
    
    @GetMapping("/search")
    public ResponseEntity<List<Product>> searchProducts(@RequestParam String query) {
        List<Product> results = productService.searchProducts(query);
        return ResponseEntity.ok(results);
    }
    
    @GetMapping("/{id}")
    public ResponseEntity<Product> getProductById(@PathVariable Long id) {
        return productService.getProductById(id)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }
    
    @GetMapping("/name/{name}")
    public ResponseEntity<Product> getProductByName(@PathVariable String name) {
        return productService.findByName(name)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }
    
    @GetMapping
    public ResponseEntity<List<Product>> getAllProducts() {
        List<Product> products = productService.getAllProducts();
        return ResponseEntity.ok(products);
    }
    
    @PostMapping
    public ResponseEntity<Product> createProduct(@RequestBody Product product) {
        Product savedProduct = productService.saveProduct(product);
        return ResponseEntity.ok(savedProduct);
    }
    
    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteProduct(@PathVariable Long id) {
        productService.deleteProduct(id);
        return ResponseEntity.noContent().build();
    }
    
    @GetMapping("/exists/{name}")
    public ResponseEntity<Boolean> productExists(@PathVariable String name) {
        boolean exists = productService.productExists(name);
        return ResponseEntity.ok(exists);
    }
    
    @GetMapping("/reason/{productName}")
    public ResponseEntity<String> getBoycottReason(@PathVariable String productName) {
        String reason = productService.getBoycottReason(productName);
        if (reason == null) {
            return ResponseEntity.notFound().build();
        }
        return ResponseEntity.ok(reason);
    }
}