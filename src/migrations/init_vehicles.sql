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

-- Sample vehicles for development
INSERT INTO vehicles (make, model, year, price, image_url) VALUES
('Example Brand', 'Sedan A', 2024, 35990.00, 'https://cwc-vehicle-images-34d0e602.s3.amazonaws.com/sedan-a-2024.jpg'),
('Example Brand', 'Sedan B', 2024, 42995.00, 'https://cwc-vehicle-images-34d0e602.s3.amazonaws.com/sedan-b-2024.jpg'),
('Example Brand', 'Sedan C', 2024, 58995.00, 'https://cwc-vehicle-images-34d0e602.s3.amazonaws.com/sedan-c-2024.jpg'),
('Example Brand', 'SUV X', 2024, 39995.00, 'https://cwc-vehicle-images-34d0e602.s3.amazonaws.com/suv-x-2024.jpg'),
('Example Brand', 'SUV Y', 2024, 49995.00, 'https://cwc-vehicle-images-34d0e602.s3.amazonaws.com/suv-y-2024.jpg');

-- Production data (different pricing/models)
-- INSERT INTO vehicles (make, model, year, price, image_url) VALUES
-- ('Premium Brand', 'Electric GT', 2024, 102995.00, 'https://cwc-vehicle-images.s3.amazonaws.com/electric-gt-2024.jpg'),
-- ('Premium Brand', 'Sport Wagon', 2024, 119995.00, 'https://cwc-vehicle-images.s3.amazonaws.com/sport-wagon-2024.jpg');