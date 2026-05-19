DROP USER IF EXISTS nexo_admin_user;
DROP USER IF EXISTS nexo_reader_user;
DROP ROLE IF EXISTS nexo_admin;
DROP ROLE IF EXISTS nexo_readonly;

CREATE ROLE nexo_admin;
CREATE ROLE nexo_readonly;

GRANT USAGE ON SCHEMA nexo_retail_db TO nexo_admin;
GRANT USAGE ON SCHEMA nexo_retail_db TO nexo_readonly;

GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA nexo_retail_db TO nexo_admin;
GRANT SELECT ON ALL TABLES IN SCHEMA nexo_retail_db TO nexo_readonly;

CREATE USER nexo_admin_user WITH PASSWORD 'admin_pass_123';
GRANT nexo_admin TO nexo_admin_user;

CREATE USER nexo_reader_user WITH PASSWORD 'reader_pass_123';
GRANT nexo_readonly TO nexo_reader_user;

REVOKE UPDATE, DELETE ON ALL TABLES IN SCHEMA nexo_retail_db FROM nexo_readonly;

SET search_path TO nexo_retail_db, public;

TRUNCATE TABLE 
    payment_transactions, 
    order_items, 
    reviews, 
    orders, 
    product_images, 
    products, 
    addresses, 
    users, 
    suppliers, 
    categories 
CASCADE;

INSERT INTO categories (category_name, description) VALUES 
    ('Electronics', 'Gadgets and devices'),
    ('Clothing', 'Fashion and apparel'),
    ('Books', 'Physical and electronic books'),
    ('Home & Kitchen', 'Appliances and decor'),
    ('Sports', 'Sporting goods and outdoor gear');

INSERT INTO suppliers (supplier_name, contact_name, email, phone_number, address) VALUES 
    ('TechCorp', 'John Doe', 'sales@techcorp.com', '+123456789', '123 Silicon Valley'),
    ('FashionHub', 'Jane Smith', 'info@fashionhub.com', '+987654321', '456 Fashion Ave'),
    ('BookDistro', 'Alan Poe', 'orders@bookdistro.com', '+11223344', '789 Library Ln'),
    ('HomeGoods Inc', 'Alice Wonderland', 'hello@homegoods.com', '+55443322', '101 Comfort St'),
    ('ActiveLife', 'Mike Tyson', 'contact@activelife.com', '+99887766', '202 Gym Rd');

INSERT INTO users (username, email, password, phone_number, gender) VALUES 
    ('alice_w', 'alice@example.com', 'hash1', '555-0101', 'F'),
    ('bob_m', 'bob@example.com', 'hash2', '555-0102', 'M'),
    ('charlie_d', 'charlie@example.com', 'hash3', '555-0103', 'M'),
    ('diana_p', 'diana@example.com', 'hash4', '555-0104', 'F'),
    ('evan_s', 'evan@example.com', 'hash5', '555-0105', 'M');

INSERT INTO addresses (user_id, city, street_address, postal_code, is_default) VALUES 
    ((SELECT user_id FROM users WHERE username = 'alice_w'), 'New York', '101 Broadway St', '10001', TRUE),
    ((SELECT user_id FROM users WHERE username = 'bob_m'), 'Los Angeles', '202 Sunset Blvd', '90001', TRUE),
    ((SELECT user_id FROM users WHERE username = 'charlie_d'), 'Chicago', '303 Wind Ave', '60007', TRUE),
    ((SELECT user_id FROM users WHERE username = 'diana_p'), 'Houston', '404 Space Rd', '77001', TRUE),
    ((SELECT user_id FROM users WHERE username = 'evan_s'), 'Phoenix', '505 Sun St', '85001', TRUE);

INSERT INTO products (category_id, supplier_id, name, description, price, stock_quantity) VALUES 
    ((SELECT category_id FROM categories WHERE category_name = 'Electronics'), (SELECT supplier_id FROM suppliers WHERE email = 'sales@techcorp.com'), 'Smartphone X', 'Latest model', 899.99, 50),
    ((SELECT category_id FROM categories WHERE category_name = 'Clothing'), (SELECT supplier_id FROM suppliers WHERE email = 'info@fashionhub.com'), 'Cotton T-Shirt', 'Organic cotton', 19.99, 200),
    ((SELECT category_id FROM categories WHERE category_name = 'Books'), (SELECT supplier_id FROM suppliers WHERE email = 'orders@bookdistro.com'), 'SQL Guide', 'Database design', 45.00, 100),
    ((SELECT category_id FROM categories WHERE category_name = 'Home & Kitchen'), (SELECT supplier_id FROM suppliers WHERE email = 'hello@homegoods.com'), 'Coffee Maker', 'Brews quickly', 79.99, 30),
    ((SELECT category_id FROM categories WHERE category_name = 'Sports'), (SELECT supplier_id FROM suppliers WHERE email = 'contact@activelife.com'), 'Yoga Mat', 'Eco-friendly', 25.50, 150);

INSERT INTO product_images (product_id, image_url, is_main) VALUES 
    ((SELECT product_id FROM products WHERE name = 'Smartphone X'), 'http://img.com/phone.jpg', TRUE),
    ((SELECT product_id FROM products WHERE name = 'Cotton T-Shirt'), 'http://img.com/tshirt.jpg', TRUE),
    ((SELECT product_id FROM products WHERE name = 'SQL Guide'), 'http://img.com/sql.jpg', TRUE),
    ((SELECT product_id FROM products WHERE name = 'Coffee Maker'), 'http://img.com/coffee.jpg', TRUE),
    ((SELECT product_id FROM products WHERE name = 'Yoga Mat'), 'http://img.com/yoga.jpg', TRUE);

INSERT INTO orders (user_id, address_id, order_date, total_amount, status) VALUES 
    ((SELECT user_id FROM users WHERE username = 'alice_w'), (SELECT address_id FROM addresses WHERE city = 'New York'), '2026-03-15 14:00:00', 899.99, 'Pending'),
    ((SELECT user_id FROM users WHERE username = 'bob_m'), (SELECT address_id FROM addresses WHERE city = 'Los Angeles'), '2026-03-16 10:30:00', 19.99, 'Processing'),
    ((SELECT user_id FROM users WHERE username = 'charlie_d'), (SELECT address_id FROM addresses WHERE city = 'Chicago'), '2026-03-17 09:15:00', 45.00, 'Shipped'),
    ((SELECT user_id FROM users WHERE username = 'diana_p'), (SELECT address_id FROM addresses WHERE city = 'Houston'), '2026-03-18 16:45:00', 79.99, 'Delivered'),
    ((SELECT user_id FROM users WHERE username = 'evan_s'), (SELECT address_id FROM addresses WHERE city = 'Phoenix'), '2026-03-19 11:20:00', 25.50, 'Pending');

INSERT INTO order_items (order_id, product_id, quantity, price_at_purchase) VALUES 
    ((SELECT order_id FROM orders WHERE total_amount = 899.99), (SELECT product_id FROM products WHERE name = 'Smartphone X'), 1, 899.99),
    ((SELECT order_id FROM orders WHERE total_amount = 19.99), (SELECT product_id FROM products WHERE name = 'Cotton T-Shirt'), 1, 19.99),
    ((SELECT order_id FROM orders WHERE total_amount = 45.00), (SELECT product_id FROM products WHERE name = 'SQL Guide'), 1, 45.00),
    ((SELECT order_id FROM orders WHERE total_amount = 79.99), (SELECT product_id FROM products WHERE name = 'Coffee Maker'), 1, 79.99),
    ((SELECT order_id FROM orders WHERE total_amount = 25.50), (SELECT product_id FROM products WHERE name = 'Yoga Mat'), 1, 25.50);

INSERT INTO payment_transactions (order_id, payment_method, amount, status) VALUES 
    ((SELECT order_id FROM orders WHERE total_amount = 899.99), 'Credit Card', 899.99, 'Completed'),
    ((SELECT order_id FROM orders WHERE total_amount = 19.99), 'PayPal', 19.99, 'Pending'),
    ((SELECT order_id FROM orders WHERE total_amount = 45.00), 'Debit Card', 45.00, 'Completed'),
    ((SELECT order_id FROM orders WHERE total_amount = 79.99), 'Crypto', 79.99, 'Completed'),
    ((SELECT order_id FROM orders WHERE total_amount = 25.50), 'Credit Card', 25.50, 'Failed');

INSERT INTO reviews (product_id, user_id, rating, comment) VALUES 
    ((SELECT product_id FROM products WHERE name = 'Smartphone X'), (SELECT user_id FROM users WHERE username = 'alice_w'), 5, 'Amazing phone!'),
    ((SELECT product_id FROM products WHERE name = 'Cotton T-Shirt'), (SELECT user_id FROM users WHERE username = 'bob_m'), 4, 'Good fit.'),
    ((SELECT product_id FROM products WHERE name = 'SQL Guide'), (SELECT user_id FROM users WHERE username = 'charlie_d'), 5, 'Very helpful book.'),
    ((SELECT product_id FROM products WHERE name = 'Coffee Maker'), (SELECT user_id FROM users WHERE username = 'diana_p'), 3, 'A bit noisy.'),
    ((SELECT product_id FROM products WHERE name = 'Yoga Mat'), (SELECT user_id FROM users WHERE username = 'evan_s'), 5, 'Perfect thickness.');

-- Price increase for Yoga Mat due to rising logistics costs
SELECT name, price AS price_before FROM products WHERE name = 'Yoga Mat';
UPDATE products SET price = 29.99 WHERE name = 'Yoga Mat';

-- Updating the status of a pending payment after manual verification
SELECT payment_method, status AS status_before FROM payment_transactions WHERE status = 'Pending';
UPDATE payment_transactions SET status = 'Completed' WHERE status = 'Pending';

SELECT p.name, p.price AS price_before, c.category_name FROM products p JOIN categories c ON p.category_id = c.category_id WHERE c.category_name = 'Clothing';
UPDATE products p SET price = p.price * 0.90 FROM categories c WHERE p.category_id = c.category_id AND c.category_name = 'Clothing';

BEGIN;

-- Removing unsuccessful transactions from the database to avoid damaging conversion statistics in dashboards
DELETE FROM payment_transactions WHERE status = 'Failed';

-- Expected row count: 1 row deleted
SELECT COUNT(*) AS remaining_failed_transactions FROM payment_transactions WHERE status = 'Failed';

ROLLBACK;
