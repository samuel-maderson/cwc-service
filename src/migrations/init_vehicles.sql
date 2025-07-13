-- Initial vehicle catalog data
USE cwc_catalog;

CREATE TABLE IF NOT EXISTS vehicles (
    id INT AUTO_INCREMENT PRIMARY KEY,
    make VARCHAR(50) NOT NULL,
    model VARCHAR(100) NOT NULL,
    year INT NOT NULL,
    price DECIMAL(10,2),
    image_url VARCHAR(500),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Sample Audi vehicles for development
INSERT INTO vehicles (make, model, year, price, image_url) VALUES
('Audi', 'A3', 2024, 35990.00, 'https://cwc-vehicle-images-34d0e602.s3.amazonaws.com/audi-a3-2024.jpg'),
('Audi', 'A5', 2024, 42995.00, 'https://cwc-vehicle-images-34d0e602.s3.amazonaws.com/audi-a5-2024.jpg'),
('Audi', 'A6', 2024, 58995.00, 'https://cwc-vehicle-images-34d0e602.s3.amazonaws.com/audi-a6-2024.jpg'),
('Audi', 'Q3', 2024, 39995.00, 'https://cwc-vehicle-images-34d0e602.s3.amazonaws.com/audi-q3-2024.jpg'),
('Audi', 'Q5', 2024, 49995.00, 'https://cwc-vehicle-images-34d0e602.s3.amazonaws.com/audi-q5-2024.jpg');

-- Production data (different pricing/models)
-- INSERT INTO vehicles (make, model, year, price, image_url) VALUES
-- ('Audi', 'e-tron GT', 2024, 102995.00, 'https://cwc-vehicle-images.s3.amazonaws.com/etron-gt-2024.jpg'),
-- ('Audi', 'RS6', 2024, 119995.00, 'https://cwc-vehicle-images.s3.amazonaws.com/rs6-2024.jpg');