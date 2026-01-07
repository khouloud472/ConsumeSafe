package com.consumesafe.entity;

import jakarta.persistence.*;
import lombok.*;

@Entity
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
@Table(name = "products")
public class Product {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private String name;
    private String description;
    private String category;
    private String brand;
    private String barcode;
    private Boolean boycotted;
    private String boycottReason;
    private String imageUrl;
    private Boolean tunisian;
    private Double price;

}
