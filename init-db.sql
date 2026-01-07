-- ============================================================
-- ConsumeSafe Database Initialization Script
-- ============================================================
-- Database: consumesafe
-- Character Set: utf8mb4
-- Created: 2026-01-07
-- ============================================================

USE consumesafe;

-- ============================================================
-- Create Products Table
-- ============================================================
CREATE TABLE IF NOT EXISTS products (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL UNIQUE,
    description VARCHAR(500),
    category VARCHAR(100) NOT NULL,
    brand VARCHAR(100),
    barcode VARCHAR(100),
    boycotted BOOLEAN NOT NULL DEFAULT FALSE,
    boycott_reason VARCHAR(500),
    tunisian BOOLEAN NOT NULL DEFAULT FALSE,
    image_url VARCHAR(255),
    price DECIMAL(10, 2),
    details VARCHAR(1000),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_name (name),
    INDEX idx_boycotted (boycotted),
    INDEX idx_tunisian (tunisian),
    INDEX idx_category (category),
    FULLTEXT INDEX ft_search (name, brand, description)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- Create Alternatives Table
-- ============================================================
CREATE TABLE IF NOT EXISTS alternatives (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    boycotted_product_id BIGINT NOT NULL,
    alternative_product_id BIGINT NOT NULL,
    reason VARCHAR(500),
    similarity_score DECIMAL(3, 2),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (boycotted_product_id) REFERENCES products(id) ON DELETE CASCADE,
    FOREIGN KEY (alternative_product_id) REFERENCES products(id) ON DELETE CASCADE,
    INDEX idx_boycotted_product (boycotted_product_id),
    INDEX idx_alternative_product (alternative_product_id),
    INDEX idx_similarity (similarity_score)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- Insert Boycotted Products (International Brands)
-- ============================================================
INSERT INTO products (name, description, category, brand, barcode, boycotted, boycott_reason, tunisian, image_url, price, details) VALUES
('Coca-Cola', 'Carbonated soft drink', 'Beverages', 'Coca-Cola', '5449000000036', TRUE, 'Company supports Israeli occupation', FALSE, NULL, 2.5, 'Famous carbonated drink'),
('Nescafé', 'Instant coffee', 'Coffee', 'Nestlé', '7613034728899', TRUE, 'Nestlé products support occupation', FALSE, NULL, 5.0, 'Instant coffee brand'),
('Starbucks Products', 'Coffee and pastries', 'Coffee Shops', 'Starbucks', NULL, TRUE, 'Starbucks supports occupation policies', FALSE, NULL, 6.0, 'Coffee and pastry products'),
('Pepsi', 'Carbonated soft drink', 'Beverages', 'PepsiCo', '012000003100', TRUE, 'Company supports occupation', FALSE, NULL, 2.5, 'Carbonated soft drink'),
('iPhone', 'Smartphone', 'Electronics', 'Apple', NULL, TRUE, 'American company supports occupation', FALSE, NULL, 1200.0, 'Premium smartphone'),
('McDonald''s', 'Fast food restaurant', 'Fast Food', 'McDonald''s', NULL, TRUE, 'Supports Israeli economy', FALSE, NULL, 8.0, 'Fast food chain'),
('L''Oréal Products', 'Cosmetics and beauty', 'Cosmetics', 'L''Oréal', NULL, TRUE, 'Company with Israeli investments', FALSE, NULL, 15.0, 'Beauty and cosmetics products'),
('Pampers', 'Baby diapers', 'Baby Care', 'Procter & Gamble', NULL, TRUE, 'Parent company supports Israel', FALSE, NULL, 12.0, 'Baby care products'),
('Nike Shoes', 'Sports shoes', 'Sportswear', 'Nike', NULL, TRUE, 'Brand with Israeli partnerships', FALSE, NULL, 80.0, 'Sports footwear'),
('Heinz Ketchup', 'Tomato ketchup', 'Condiments', 'Kraft Heinz', NULL, TRUE, 'Company supports Israeli economy', FALSE, NULL, 3.5, 'Tomato ketchup');

-- ============================================================
-- Insert Tunisian Products
-- ============================================================
INSERT INTO products (name, description, category, brand, barcode, boycotted, boycott_reason, tunisian, image_url, price, details) VALUES
('Tunisian Coffee Hilal', 'Locally produced coffee', 'Coffee', 'Hilal', '9876543210', FALSE, NULL, TRUE, NULL, 3.5, 'High quality Tunisian coffee'),
('Tunisian Orange Juice', 'Fresh orange juice', 'Beverages', 'Safaksi', '1234567890', FALSE, NULL, TRUE, NULL, 2.0, 'Fresh juice from Sfax region'),
('Tunisian Dates', 'Dry dates', 'Sweets', 'Tunisian Dates', '5555555555', FALSE, NULL, TRUE, NULL, 15.0, 'Premium dates from Tunisian oases'),
('Tunisian Harissa', 'Hot chili paste', 'Spices', 'Um Aliya', '3333333333', FALSE, NULL, TRUE, NULL, 4.5, 'Traditional Tunisian hot sauce'),
('Tunisian Couscous', 'Whole grain couscous', 'Grains', 'Tunisian Field', '4444444444', FALSE, NULL, TRUE, NULL, 8.0, 'Traditional couscous from Northern regions'),
('Tunisian Olive Oil', 'Organic olive oil', 'Oils', 'Tunis Oasis', '6666666666', FALSE, NULL, TRUE, NULL, 18.0, 'Extra virgin olive oil from Sfax'),
('Tunisian Honey', 'Natural honey', 'Sweeteners', 'Tunisian Bees', '7777777777', FALSE, NULL, TRUE, NULL, 25.0, 'Natural Sidr honey from the North'),
('Delice Biscuits', 'Tunisian biscuits', 'Snacks', 'Delice', '8888888888', FALSE, NULL, TRUE, NULL, 2.8, 'Popular Tunisian biscuits'),
('Tunisian Mint Tea', 'Traditional mint tea', 'Tea', 'Tunis Tea', '9999999999', FALSE, NULL, TRUE, NULL, 5.5, 'Traditional Tunisian mint tea'),
('Jeben Cheese', 'White cheese', 'Dairy', 'Jeben', '1010101010', FALSE, NULL, TRUE, NULL, 4.0, 'Traditional Tunisian white cheese'),
('Tunisian Sardines', 'Canned sardines', 'Seafood', 'Sfax Sardines', '1111111111', FALSE, NULL, TRUE, NULL, 3.0, 'Canned sardines from Sfax coast'),
('Tunisian Rose Water', 'Natural rose water', 'Cosmetics', 'Tunisian Roses', '1212121212', FALSE, NULL, TRUE, NULL, 7.0, 'Natural rose water for cosmetics');

-- ============================================================
-- Insert Alternatives (Relations)
-- ============================================================
INSERT INTO alternatives (boycotted_product_id, alternative_product_id, reason, similarity_score) VALUES
((SELECT id FROM products WHERE name = 'Coca-Cola'), (SELECT id FROM products WHERE name = 'Tunisian Orange Juice'), 'Healthy Tunisian juice alternative', 0.85),
((SELECT id FROM products WHERE name = 'Nescafé'), (SELECT id FROM products WHERE name = 'Tunisian Coffee Hilal'), 'Locally produced Tunisian coffee', 0.90),
((SELECT id FROM products WHERE name = 'Starbucks Products'), (SELECT id FROM products WHERE name = 'Tunisian Coffee Hilal'), 'High quality Tunisian coffee alternative', 0.88),
((SELECT id FROM products WHERE name = 'Coca-Cola'), (SELECT id FROM products WHERE name = 'Tunisian Dates'), 'Healthy Tunisian sweets alternative', 0.75),
((SELECT id FROM products WHERE name = 'Pepsi'), (SELECT id FROM products WHERE name = 'Tunisian Orange Juice'), 'Natural Tunisian juice', 0.85),
((SELECT id FROM products WHERE name = 'McDonald''s'), (SELECT id FROM products WHERE name = 'Tunisian Dates'), 'Healthy snack alternative', 0.70),
((SELECT id FROM products WHERE name = 'L''Oréal Products'), (SELECT id FROM products WHERE name = 'Tunisian Rose Water'), 'Natural Tunisian cosmetic alternative', 0.82),
((SELECT id FROM products WHERE name = 'iPhone'), (SELECT id FROM products WHERE name = 'Tunisian Honey'), 'Premium Tunisian product', 0.60),
((SELECT id FROM products WHERE name = 'Nike Shoes'), (SELECT id FROM products WHERE name = 'Tunisian Sardines'), 'Support local economy instead', 0.55),
((SELECT id FROM products WHERE name = 'Heinz Ketchup'), (SELECT id FROM products WHERE name = 'Tunisian Harissa'), 'Spicy Tunisian alternative', 0.78),
((SELECT id FROM products WHERE name = 'Pampers'), (SELECT id FROM products WHERE name = 'Tunisian Olive Oil'), 'Natural Tunisian product', 0.65);

-- ============================================================
-- Create Users Table (Future use)
-- ============================================================
CREATE TABLE IF NOT EXISTS users (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(100) UNIQUE NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    role VARCHAR(50) DEFAULT 'USER',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_username (username),
    INDEX idx_email (email)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- Create Reviews Table (Future use)
-- ============================================================
CREATE TABLE IF NOT EXISTS reviews (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    product_id BIGINT NOT NULL,
    user_id BIGINT,
    rating INT CHECK (rating BETWEEN 1 AND 5),
    comment TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE SET NULL,
    INDEX idx_product (product_id),
    INDEX idx_user (user_id),
    INDEX idx_rating (rating)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- Create Statistics Table
-- ============================================================
CREATE TABLE IF NOT EXISTS statistics (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    total_products INT DEFAULT 0,
    total_boycotted INT DEFAULT 0,
    total_tunisian INT DEFAULT 0,
    total_searches INT DEFAULT 0,
    last_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- Insert Initial Statistics
-- ============================================================
INSERT INTO statistics (total_products, total_boycotted, total_tunisian, total_searches) VALUES
(22, 10, 12, 0);

-- ============================================================
-- Create Views for Common Queries
-- ============================================================
CREATE OR REPLACE VIEW view_boycotted_products AS
SELECT id, name, brand, category, boycott_reason, price 
FROM products 
WHERE boycotted = TRUE 
ORDER BY name;

CREATE OR REPLACE VIEW view_tunisian_products AS
SELECT id, name, brand, category, price, details 
FROM products 
WHERE tunisian = TRUE 
ORDER BY name;

CREATE OR REPLACE VIEW view_alternatives_summary AS
SELECT 
    p1.name AS boycotted_product,
    p2.name AS tunisian_alternative,
    a.reason,
    a.similarity_score
FROM alternatives a
JOIN products p1 ON a.boycotted_product_id = p1.id
JOIN products p2 ON a.alternative_product_id = p2.id
ORDER BY a.similarity_score DESC;

-- ============================================================
-- Create Search Logs Table
-- ============================================================
CREATE TABLE IF NOT EXISTS search_logs (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    search_term VARCHAR(255) NOT NULL,
    search_count INT DEFAULT 1,
    last_searched TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_search_term (search_term),
    INDEX idx_search_count (search_count)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- Create Categories Table
-- ============================================================
CREATE TABLE IF NOT EXISTS categories (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) UNIQUE NOT NULL,
    description VARCHAR(255),
    icon VARCHAR(50),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Insert default categories
INSERT INTO categories (name, description, icon) VALUES
('Beverages', 'Drinks and beverages', 'glass'),
('Coffee', 'Coffee products', 'coffee'),
('Fast Food', 'Fast food restaurants', 'hamburger'),
('Cosmetics', 'Beauty products', 'lipstick'),
('Electronics', 'Electronic devices', 'smartphone'),
('Baby Care', 'Baby products', 'baby'),
('Sportswear', 'Sports clothing', 'shoe'),
('Condiments', 'Sauces and condiments', 'bottle'),
('Sweets', 'Sweet products', 'cookie'),
('Spices', 'Spices and seasonings', 'spice'),
('Grains', 'Grain products', 'wheat'),
('Oils', 'Oils and fats', 'oil'),
('Sweeteners', 'Sweetening products', 'honey'),
('Snacks', 'Snack foods', 'popcorn'),
('Tea', 'Tea products', 'tea'),
('Dairy', 'Dairy products', 'milk'),
('Seafood', 'Sea products', 'fish');

-- ============================================================
-- Set Privileges for ConsumeSafe User
-- ============================================================
CREATE USER IF NOT EXISTS 'consumesafe'@'%' IDENTIFIED BY 'securepassword123';
GRANT ALL PRIVILEGES ON consumesafe.* TO 'consumesafe'@'%';
FLUSH PRIVILEGES;

-- ============================================================
-- Display Summary
-- ============================================================
SELECT 'ConsumeSafe Database Initialized Successfully ✓' AS status;
SELECT CONCAT('Total Products: ', COUNT(*)) AS summary FROM products;
SELECT CONCAT('Boycotted Products: ', COUNT(*)) AS summary FROM products WHERE boycotted = TRUE;
SELECT CONCAT('Tunisian Products: ', COUNT(*)) AS summary FROM products WHERE tunisian = TRUE;
SELECT CONCAT('Alternative Relations: ', COUNT(*)) AS summary FROM alternatives;
SELECT CONCAT('Categories: ', COUNT(*)) AS summary FROM categories;

-- Display some sample data
SELECT 'Sample Boycotted Products:' AS section;
SELECT name, brand, category, boycott_reason FROM products WHERE boycotted = TRUE LIMIT 5;

SELECT 'Sample Tunisian Alternatives:' AS section;
SELECT name, brand, category, price FROM products WHERE tunisian = TRUE LIMIT 5;

SELECT 'Sample Alternative Relations:' AS section;
SELECT 
    p1.name AS 'Boycotted Product',
    p2.name AS 'Tunisian Alternative',
    a.similarity_score AS 'Match Score'
FROM alternatives a
JOIN products p1 ON a.boycotted_product_id = p1.id
JOIN products p2 ON a.alternative_product_id = p2.id
LIMIT 5;