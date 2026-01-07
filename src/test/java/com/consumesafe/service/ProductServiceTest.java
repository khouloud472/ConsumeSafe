package com.consumesafe.service;

import com.consumesafe.entity.Product;
import com.consumesafe.repository.ProductRepository;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.util.Optional;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.Mockito.when;

@ExtendWith(MockitoExtension.class)
class ProductServiceTest {

    @Mock
    private ProductRepository productRepository;

    @InjectMocks
    private ProductService productService;

    @Test
    void testFindByName_ProductExists() {
        // Given
        Product product = Product.builder()
                .id(1L)
                .name("Test Product")
                .boycotted(false)
                .tunisian(true)
                .build();
        
        when(productRepository.findByNameIgnoreCase("Test Product"))
                .thenReturn(Optional.of(product));

        // When
        Optional<Product> result = productService.findByName("Test Product");

        // Then
        assertThat(result).isPresent();
        assertThat(result.get().getName()).isEqualTo("Test Product");
    }

    @Test
    void testFindByName_ProductNotFound() {
        // Given
        when(productRepository.findByNameIgnoreCase(anyString()))
                .thenReturn(Optional.empty());

        // When
        Optional<Product> result = productService.findByName("Non-existent");

        // Then
        assertThat(result).isEmpty();
    }
}