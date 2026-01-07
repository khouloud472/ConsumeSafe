package com.exemple.controller;

import com.exemple.dto.ProductCheckResponse;
import com.exemple.model.Product;
import com.exemple.service.ProductService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import java.util.List;

@RestController
@RequestMapping("/products")
@CrossOrigin(origins = "*", allowedHeaders = "*", methods = {RequestMethod.GET, RequestMethod.POST, RequestMethod.OPTIONS})
public class ProductController {

    @Autowired
    private ProductService productService;

    @PostMapping("/check")
    public ResponseEntity<ProductCheckResponse> checkProduct(@RequestParam String name) {
        ProductCheckResponse response = productService.checkProduct(name);
        return ResponseEntity.ok(response);
    }

    @GetMapping("/check")
    public ResponseEntity<ProductCheckResponse> checkProductGet(@RequestParam String name) {
        ProductCheckResponse response = productService.checkProduct(name);
        return ResponseEntity.ok(response);
    }

    @PostMapping("/check-barcode")
    public ResponseEntity<ProductCheckResponse> checkByBarcode(@RequestParam String barcode) {
        ProductCheckResponse response = productService.checkProductByBarcode(barcode);
        return ResponseEntity.ok(response);
    }

    @GetMapping("/check-barcode")
    public ResponseEntity<ProductCheckResponse> checkByBarcodeGet(@RequestParam String barcode) {
        ProductCheckResponse response = productService.checkProductByBarcode(barcode);
        return ResponseEntity.ok(response);
    }

    @GetMapping("/search")
    public ResponseEntity<List<Product>> searchProducts(@RequestParam String query) {
        List<Product> products = productService.searchProducts(query);
        return ResponseEntity.ok(products);
    }

    @GetMapping("/tunisian")
    public ResponseEntity<List<Product>> getTunisianProducts() {
        List<Product> products = productService.getTunisianProducts();
        return ResponseEntity.ok(products);
    }

    @GetMapping("/boycotted")
    public ResponseEntity<List<Product>> getBoycottedProducts() {
        List<Product> products = productService.getBoycottedProducts();
        return ResponseEntity.ok(products);
    }

    @PostMapping("/add")
    public ResponseEntity<String> addProduct(@RequestBody Product product) {
        productService.addProduct(product);
        return ResponseEntity.ok("Product added successfully");
    }

    @PostMapping("/alternative")
    public ResponseEntity<String> addAlternative(
            @RequestParam Long boycottedId,
            @RequestParam Long alternativeId,
            @RequestParam String reason,
            @RequestParam(required = false) Double similarityScore) {
        productService.addAlternative(boycottedId, alternativeId, reason, similarityScore);
        return ResponseEntity.ok("Alternative added successfully");
    }

    @GetMapping("/health")
    public ResponseEntity<String> health() {
        return ResponseEntity.ok("ConsumeSafe API is running!");
    }
}
