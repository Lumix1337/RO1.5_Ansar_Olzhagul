-- Database and Schema Setup
CREATE SCHEMA IF NOT EXISTS nexo_retail_db;
SET search_path TO nexo_retail_db;

CREATE TABLE IF NOT EXISTS users (
    user_id SERIAL PRIMARY KEY,
    username VARCHAR(50) NOT NULL UNIQUE,
    email VARCHAR(100) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    phone_number VARCHAR(30),
    gender CHAR(1),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_gender CHECK (gender IN ('M', 'F', 'O'))
);

CREATE TABLE IF NOT EXISTS addresses (
    address_id SERIAL PRIMARY KEY,
    user_id INT NOT NULL,
    city VARCHAR(100) NOT NULL,
    street_address TEXT NOT NULL,
    postal_code VARCHAR(20),
    is_default BOOLEAN DEFAULT FALSE,
    CONSTRAINT fk_user FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS categories (
    category_id SERIAL PRIMARY KEY,
    category_name VARCHAR(100) NOT NULL UNIQUE,
    description TEXT
);

CREATE TABLE IF NOT EXISTS suppliers (
    supplier_id SERIAL PRIMARY KEY,
    supplier_name VARCHAR(100) NOT NULL,
    contact_name VARCHAR(100),
    email VARCHAR(100) UNIQUE,
    phone_number VARCHAR(20),
    address TEXT
);

CREATE TABLE IF NOT EXISTS products (
    product_id SERIAL PRIMARY KEY,
    category_id INT NOT NULL,
    supplier_id INT NOT NULL,
    name VARCHAR(150) NOT NULL,
    description TEXT,
    price DECIMAL(10, 2) NOT NULL,
    stock_quantity INT NOT NULL DEFAULT 0,
    CONSTRAINT chk_price_pos CHECK (price >= 0),
    CONSTRAINT chk_stock_pos CHECK (stock_quantity >= 0),
    CONSTRAINT fk_category FOREIGN KEY (category_id) REFERENCES categories(category_id),
    CONSTRAINT fk_supplier FOREIGN KEY (supplier_id) REFERENCES suppliers(supplier_id)
);

CREATE TABLE IF NOT EXISTS product_images (
    image_id SERIAL PRIMARY KEY,
    product_id INT NOT NULL,
    image_url TEXT NOT NULL,
    is_main BOOLEAN DEFAULT FALSE,
    added_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_product FOREIGN KEY (product_id) REFERENCES products(product_id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS orders (
    order_id SERIAL PRIMARY KEY,
    user_id INT NOT NULL,
    address_id INT NOT NULL,
    order_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    total_amount DECIMAL(10, 2) NOT NULL DEFAULT 0.00,
    status VARCHAR(50) DEFAULT 'Pending',
    CONSTRAINT chk_order_date CHECK (order_date > '2026-01-01 00:00:00'::TIMESTAMP),
    CONSTRAINT fk_user_order FOREIGN KEY (user_id) REFERENCES users(user_id),
    CONSTRAINT fk_address_order FOREIGN KEY (address_id) REFERENCES addresses(address_id)
);

CREATE TABLE IF NOT EXISTS order_items (
    order_item_id SERIAL PRIMARY KEY,
    order_id INT NOT NULL,
    product_id INT NOT NULL,
    quantity INT NOT NULL,
    price_at_purchase DECIMAL(10, 2) NOT NULL,
    row_total DECIMAL(10, 2) GENERATED ALWAYS AS (quantity * price_at_purchase) STORED,
    CONSTRAINT chk_qty_pos CHECK (quantity > 0),
    CONSTRAINT fk_order FOREIGN KEY (order_id) REFERENCES orders(order_id) ON DELETE CASCADE,
    CONSTRAINT fk_product_item FOREIGN KEY (product_id) REFERENCES products(product_id)
);

CREATE TABLE IF NOT EXISTS payment_transactions (
    transaction_id SERIAL PRIMARY KEY,
    order_id INT NOT NULL,
    payment_method VARCHAR(50) NOT NULL,
    amount DECIMAL(10, 2) NOT NULL,
    transaction_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    status VARCHAR(50) NOT NULL,
    CONSTRAINT chk_pay_amount CHECK (amount > 0),
    CONSTRAINT fk_order_trans FOREIGN KEY (order_id) REFERENCES orders(order_id)
);

CREATE TABLE IF NOT EXISTS reviews (
    review_id SERIAL PRIMARY KEY,
    product_id INT NOT NULL,
    user_id INT NOT NULL,
    rating INT NOT NULL CHECK (rating BETWEEN 1 AND 5),
    comment TEXT,
    review_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_product_rev FOREIGN KEY (product_id) REFERENCES products(product_id),
    CONSTRAINT fk_user_rev FOREIGN KEY (user_id) REFERENCES users(user_id)
);

INSERT INTO categories (category_name, description)
VALUES 
    ('Electronics', 'Gadgets and devices'),
    ('Clothing', 'Fashion and apparel')
ON CONFLICT (category_name) DO NOTHING;

INSERT INTO suppliers (supplier_name, contact_name, email, phone_number, address)
VALUES 
    ('TechCorp', 'John Doe', 'sales@techcorp.com', '+123456789', '123 Silicon Valley'),
    ('FashionHub', 'Jane Smith', 'info@fashionhub.com', '+987654321', '456 Fashion Ave')
ON CONFLICT (email) DO NOTHING;

INSERT INTO users (username, email, password, phone_number, gender)
VALUES 
    ('alice_w', 'alice@example.com', 'hash_123', '555-0101', 'F'),
    ('bob_m', 'bob@example.com', 'hash_456', '555-0102', 'M')
ON CONFLICT (username) DO NOTHING;

INSERT INTO addresses (user_id, city, street_address, postal_code, is_default)
VALUES 
    (1, 'New York', '101 Broadway St', '10001', TRUE),
    (2, 'Los Angeles', '202 Sunset Blvd', '90001', TRUE)
ON CONFLICT DO NOTHING;

INSERT INTO products (category_id, supplier_id, name, description, price, stock_quantity)
VALUES 
    (1, 1, 'Smartphone X', 'Latest model', 899.99, 50),
    (2, 2, 'Cotton T-Shirt', 'Organic cotton', 19.99, 200)
ON CONFLICT DO NOTHING;

INSERT INTO orders (user_id, address_id, order_date, total_amount, status)
VALUES 
    (1, 1, '2026-03-15 14:00:00', 899.99, 'Pending'),
    (2, 2, '2026-03-16 10:30:00', 19.99, 'Processing')
ON CONFLICT DO NOTHING;

INSERT INTO order_items (order_id, product_id, quantity, price_at_purchase)
VALUES 
    (1, 1, 1, 899.99),
    (2, 2, 1, 19.99)
ON CONFLICT DO NOTHING;

INSERT INTO payment_transactions (order_id, payment_method, amount, status)
VALUES 
    (1, 'Credit Card', 899.99, 'Completed'),
    (2, 'PayPal', 19.99, 'Pending')
ON CONFLICT DO NOTHING;

INSERT INTO reviews (product_id, user_id, rating, comment)
VALUES 
    (1, 1, 5, 'Excellent device!'),
    (2, 2, 4, 'Very comfortable.')
ON CONFLICT DO NOTHING;
