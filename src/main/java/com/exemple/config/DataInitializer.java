package com.exemple.config;

import com.exemple.model.Product;
import com.exemple.repository.ProductRepository;
import com.exemple.repository.AlternativeRepository;
import com.exemple.model.Alternative;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.ApplicationRunner;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
public class DataInitializer {

    @Autowired
    private ProductRepository productRepository;

    @Autowired
    private AlternativeRepository alternativeRepository;

    @Bean
    public ApplicationRunner initializeData() {
        return args -> {
            // Initialize data
            if (productRepository.count() == 0) {
                // Boycott products
                Product cocaCola = new Product(null, "Coca-Cola", "Soft drink", "Beverages", "Coca-Cola", "5449000000036", true, 
                    "Company supporting Israeli occupation", false, null, 2.5, "Soft drink");
                
                Product nestle = new Product(null, "Nescafe", "Instant coffee", "Coffee", "Nescafe", "7613034728899", true,
                    "Nestle products supporting occupation", false, null, 5.0, "Instant coffee");

                Product starbucks = new Product(null, "Starbucks products", "Coffee and pastries", "Cafes", "Starbucks", null, true,
                    "Starbucks supporting occupation", false, null, 6.0, "Coffee and pastries");

                // Tunisian safe products
                Product cafeTunisien = new Product(null, "Tunisian Coffee", "Local coffee", "Coffee", "Halal Coffee", "9876543210", false,
                    null, true, null, 3.5, "High quality Tunisian coffee");

                Product jusOrange = new Product(null, "Tunisian Orange Juice", "Fresh juice", "Beverages", "Sfaxian", "1234567890", false,
                    null, true, null, 2.0, "Orange juice from Sfax region");

                Product dateTunisia = new Product(null, "Tunisian Dates", "Dried dates", "Sweets", "Tunisian Dates", "5555555555", false,
                    null, true, null, 15.0, "Tunisian dates from coastal oases");

                Product harissaTunisia = new Product(null, "Tunisian Harissa", "Spicy paste", "Spices", "Mother's Kitchen", "3333333333", false,
                    null, true, null, 4.5, "Traditional Tunisian harissa");

                Product mlouhiaTunisia = new Product(null, "Tunisian Mloukhia", "Whole grains", "Grains", "Tunisian Field", "4444444444", false,
                    null, true, null, 8.0, "Mloukhia from northern regions");

                // Save products
                productRepository.save(cocaCola);
                productRepository.save(nestle);
                productRepository.save(starbucks);
                productRepository.save(cafeTunisien);
                productRepository.save(jusOrange);
                productRepository.save(dateTunisia);
                productRepository.save(harissaTunisia);
                productRepository.save(mlouhiaTunisia);

                // Add alternatives
                Alternative alt1 = new Alternative(null, cocaCola, jusOrange, "Healthy Tunisian juice alternative", 0.85);
                Alternative alt2 = new Alternative(null, nestle, cafeTunisien, "Tunisian made coffee", 0.90);
                Alternative alt3 = new Alternative(null, starbucks, cafeTunisien, "High quality Tunisian coffee", 0.88);
                Alternative alt4 = new Alternative(null, cocaCola, dateTunisia, "Healthy Tunisian sweets", 0.75);

                alternativeRepository.save(alt1);
                alternativeRepository.save(alt2);
                alternativeRepository.save(alt3);
                alternativeRepository.save(alt4);

                System.out.println("Initial data loaded successfully!");
            }
        };
    }
}
