BEGIN;

WITH cancelled_order AS (
    UPDATE orders
    SET status = 'cancelled'
    WHERE order_id = :'order_id'::integer
      AND status = 'reserved'
    RETURNING order_id
),
returned_items AS (
    SELECT i.product_id, i.quantity
    FROM order_items AS i
    JOIN cancelled_order AS c ON c.order_id = i.order_id
)
UPDATE products AS p
SET available = p.available + r.quantity
FROM returned_items AS r
WHERE p.product_id = r.product_id
RETURNING p.product_id, r.quantity AS returned_quantity, p.available;

SELECT
    :'order_id'::integer AS order_id,
    COALESCE(
        (SELECT status FROM orders WHERE order_id = :'order_id'::integer),
        'missing'
    ) AS current_status;

COMMIT;
