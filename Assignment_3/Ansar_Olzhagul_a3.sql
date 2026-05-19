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

TRUNCATE TABLE payment_transactions, order_items, orders, reviews, product_images, products, suppliers, categories, addresses, users CASCADE;

INSERT INTO categories (category_name, description)
VALUES 
	('Electronics', 'Gadgets and devices'),
	('Clothing', 'Fashion and apparel'),
	('Books', 'Physical and electronic books'),
	('Home & Kitchen', 'Appliances and decor'),
	('Sports', 'Sporting goods and outdoor gear');

INSERT INTO suppliers (supplier_name, contact_name, email, phone_number, address)
VALUES 
	('TechCorp', 'John Doe', 'sales@techcorp.com', '+123456789', '123 Silicon Valley'),
	('FashionHub', 'Jane Smith', 'info@fashionhub.com', '+987654321', '456 Fashion Ave'),
	('BookDistro', 'Alan Poe', 'orders@bookdistro.com', '+11223344', '789 Library Ln');

INSERT INTO products (name, description, price, stock_quantity, category_id, supplier_id)
VALUES 
	('Smartphone X', 'Latest flagship model', 899.99, 50, (SELECT category_id FROM categories WHERE category_name = 'Electronics'), (SELECT supplier_id FROM suppliers WHERE email = 'sales@techcorp.com')),
	('Cotton T-Shirt', '100% Organic cotton', 19.99, 200, (SELECT category_id FROM categories WHERE category_name = 'Clothing'), (SELECT supplier_id FROM suppliers WHERE email = 'info@fashionhub.com')),
	('Laptop Pro', 'High performance laptop', 1299.99, 15, (SELECT category_id FROM categories WHERE category_name = 'Electronics'), (SELECT supplier_id FROM suppliers WHERE email = 'sales@techcorp.com')),
	('SQL Guide', 'Learn database design', 45.00, 100, (SELECT category_id FROM categories WHERE category_name = 'Books'), (SELECT supplier_id FROM suppliers WHERE email = 'orders@bookdistro.com')),
	('Wireless Earbuds', 'Noise-canceling sound', 149.99, 80, (SELECT category_id FROM categories WHERE category_name = 'Electronics'), (SELECT supplier_id FROM suppliers WHERE email = 'sales@techcorp.com'));

INSERT INTO product_images (product_id, image_url, is_main)
VALUES 
	((SELECT product_id FROM products WHERE name = 'Smartphone X'), 'http://example.com/phone_x.jpg', TRUE),
	((SELECT product_id FROM products WHERE name = 'Cotton T-Shirt'), 'http://example.com/tshirt.jpg', TRUE),
	((SELECT product_id FROM products WHERE name = 'Laptop Pro'), 'http://example.com/laptop.jpg', TRUE),
	((SELECT product_id FROM products WHERE name = 'SQL Guide'), 'http://example.com/sql_book.jpg', TRUE),
	((SELECT product_id FROM products WHERE name = 'Wireless Earbuds'), 'http://example.com/earbuds.jpg', TRUE);

UPDATE products 
SET price = 849.99 
WHERE name = 'Smartphone X';

UPDATE products 
SET stock_quantity = 120 
WHERE price < 50.00;

UPDATE products p
SET price = p.price + 10.00
FROM categories c
WHERE p.category_id = c.category_id 
AND c.category_name = 'Electronics';

BEGIN;
DELETE FROM products 
WHERE stock_quantity = 0;
SELECT COUNT(*) FROM products;
ROLLBACK;