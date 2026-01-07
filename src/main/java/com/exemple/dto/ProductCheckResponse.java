package com.exemple.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import java.util.List;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class ProductCheckResponse {
    private Long productId;
    private String productName;
    private String brand;
    private boolean boycotted;
    private String boycottReason;
    private List<AlternativeDto> suggestions;
    private String message;
    private String status; // "SAFE", "BOYCOTTED", "NOT_FOUND"

    @Data
    @NoArgsConstructor
    @AllArgsConstructor
    public static class AlternativeDto {
        private Long productId;
        private String name;
        private String brand;
        private String category;
        private Double price;
        private String imageUrl;
        private Double similarityScore;
        private String reason;
    }
}
