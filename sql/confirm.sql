BEGIN;

UPDATE orders
SET status = 'confirmed'
WHERE order_id = :'order_id'::integer
  AND status = 'reserved'
RETURNING order_id, status;

SELECT
    :'order_id'::integer AS order_id,
    COALESCE(
        (SELECT status FROM orders WHERE order_id = :'order_id'::integer),
        'missing'
    ) AS current_status;

COMMIT;
