BEGIN ISOLATION LEVEL READ COMMITTED;

-- Lock the order first, then its products in a consistent order.
SELECT order_id
FROM orders
WHERE order_id = :'order_id'::integer
FOR UPDATE;

SELECT p.product_id
FROM products AS p
WHERE p.product_id IN (
    SELECT i.product_id
    FROM order_items AS i
    WHERE i.order_id = :'order_id'::integer
)
ORDER BY p.product_id
FOR UPDATE OF p;

WITH required AS (
    SELECT order_id, product_id, quantity AS needed
    FROM order_items
    WHERE order_id = :'order_id'::integer
),
reserved_order AS (
    UPDATE orders AS o
    SET status = 'reserved'
    WHERE o.order_id = :'order_id'::integer
      AND o.status = 'draft'
      AND EXISTS (SELECT 1 FROM required)
      AND NOT EXISTS (
          SELECT 1
          FROM required AS r
          JOIN products AS p ON p.product_id = r.product_id
          WHERE p.available < r.needed
      )
    RETURNING o.order_id
)
UPDATE products AS p
SET available = p.available - r.needed
FROM required AS r
JOIN reserved_order AS o ON o.order_id = r.order_id
WHERE p.product_id = r.product_id
RETURNING p.product_id, r.needed AS reserved_quantity, p.available;

SELECT
    :'order_id'::integer AS order_id,
    COALESCE(
        (SELECT status FROM orders WHERE order_id = :'order_id'::integer),
        'missing'
    ) AS current_status;

COMMIT;