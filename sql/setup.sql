BEGIN;

CREATE TABLE products (
    product_id integer PRIMARY KEY,
    product_name text NOT NULL,
    available integer NOT NULL CHECK (available >= 0)
);

CREATE TABLE orders (
    order_id integer PRIMARY KEY,
    ordered_on date NOT NULL,
    status text NOT NULL DEFAULT 'draft'
        CHECK (status IN ('draft', 'reserved', 'confirmed', 'cancelled'))
);

CREATE TABLE order_items (
    order_id integer NOT NULL REFERENCES orders,
    product_id integer NOT NULL REFERENCES products,
    quantity integer NOT NULL CHECK (quantity > 0),
    unit_price numeric(10, 2) NOT NULL CHECK (unit_price >= 0),
    PRIMARY KEY (order_id, product_id)
);

INSERT INTO products VALUES (1, 'Product A', 5), (2, 'Product B', 1), (3, 'Product C', 4);
INSERT INTO orders VALUES
    (101, '2025-01-05', 'draft'), (102, '2025-01-06', 'draft'),
    (103, '2025-01-07', 'draft'), (104, '2025-01-08', 'draft');
INSERT INTO order_items VALUES
    (101, 1, 2, 12.50), (101, 2, 2, 14.00),
    (102, 1, 3, 12.50), (102, 2, 1, 14.00),
    (103, 1, 4, 12.50), (104, 3, 2, 10.00);

COMMIT;
