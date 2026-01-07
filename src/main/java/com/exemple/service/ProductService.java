package com.exemple.service;

import com.exemple.dto.ProductCheckResponse;
import com.exemple.model.Alternative;
import com.exemple.model.Product;
import com.exemple.repository.AlternativeRepository;
import com.exemple.repository.ProductRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

@Service
@Transactional
public class ProductService {

    private final ProductRepository productRepository;
    private final AlternativeRepository alternativeRepository;

    @Autowired
    public ProductService(ProductRepository productRepository, 
                         AlternativeRepository alternativeRepository) {
        this.productRepository = productRepository;
        this.alternativeRepository = alternativeRepository;
    }

    public ProductCheckResponse checkProduct(String productName) {
        ProductCheckResponse response = new ProductCheckResponse();
        
        Optional<Product> productOpt = productRepository.findByNameIgnoreCase(productName);
        
        if (!productOpt.isPresent()) {
            response.setStatus("NOT_FOUND");
            response.setMessage("Product not found");
            return response;
        }

        Product product = productOpt.get();
        response.setProductId(product.getId());
        response.setProductName(product.getName());
        response.setBrand(product.getBrand());
        response.setBoycotted(product.isBoycotted());

        if (product.isBoycotted()) {
            response.setStatus("BOYCOTTED");
            response.setBoycottReason(product.getBoycottReason());
            response.setMessage("This product may be on the boycott list!");

            // Get Tunisian alternatives
            List<Alternative> alternatives = alternativeRepository
                    .findByBoycottedProductOrderBySimilarityScoreDesc(product);

            List<ProductCheckResponse.AlternativeDto> suggestions = alternatives.stream()
                    .map(alt -> {
                        Product altProduct = alt.getAlternativeProduct();
                        return new ProductCheckResponse.AlternativeDto(
                                altProduct.getId(),
                                altProduct.getName(),
                                altProduct.getBrand(),
                                altProduct.getCategory(),
                                altProduct.getPrice(),
                                altProduct.getImageUrl(),
                                alt.getSimilarityScore(),
                                alt.getReason()
                        );
                    })
                    .collect(Collectors.toList());

            response.setSuggestions(suggestions);
        } else {
            response.setStatus("SAFE");
            response.setMessage("This product is safe to consume");
        }

        return response;
    }

    public ProductCheckResponse checkProductByBarcode(String barcode) {
        Optional<Product> productOpt = productRepository.findByBarcode(barcode);
        
        if (!productOpt.isPresent()) {
            ProductCheckResponse response = new ProductCheckResponse();
            response.setStatus("NOT_FOUND");
            response.setMessage("Product not found");
            return response;
        }

        return checkProduct(productOpt.get().getName());
    }

    public List<Product> searchProducts(String searchTerm) {
        return productRepository.findByNameContainingIgnoreCaseOrBrandContainingIgnoreCase(
            searchTerm, searchTerm);
    }

    public List<Product> getTunisianProducts() {
        return productRepository.findByTunisian(true);
    }

    public List<Product> getBoycottedProducts() {
        return productRepository.findByBoycotted(true);
    }

    public void addProduct(Product product) {
        productRepository.save(product);
    }

    public void addAlternative(Long boycottedProductId, Long alternativeProductId, 
                                      String reason, Double similarityScore) {
        Optional<Product> boycotted = productRepository.findById(boycottedProductId);
        Optional<Product> alternative = productRepository.findById(alternativeProductId);

        if (boycotted.isPresent() && alternative.isPresent()) {
            Alternative alt = new Alternative();
            alt.setBoycottedProduct(boycotted.get());
            alt.setAlternativeProduct(alternative.get());
            alt.setReason(reason);
            alt.setSimilarityScore(similarityScore != null ? similarityScore : 0.95);
            alternativeRepository.save(alt);
        } else {
            throw new IllegalArgumentException("Product not found");
        }
    }
}