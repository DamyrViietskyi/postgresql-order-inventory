-- Daily order value by current status. Only confirmed value is booked sales.
WITH order_totals AS (
    SELECT order_id, SUM(quantity * unit_price) AS order_value
    FROM order_items
    GROUP BY order_id
)
SELECT o.ordered_on, o.status, COUNT(*) AS orders,
       COALESCE(SUM(t.order_value), 0) AS order_value
FROM orders AS o
LEFT JOIN order_totals AS t USING (order_id)
GROUP BY o.ordered_on, o.status
ORDER BY o.ordered_on, o.status;

-- Compare available stock with current open demand.
WITH demand AS (
    SELECT i.product_id,
           SUM(i.quantity) FILTER (WHERE o.status = 'draft') AS draft_units,
           SUM(i.quantity) FILTER (WHERE o.status = 'reserved') AS reserved_units
    FROM order_items AS i
    JOIN orders AS o USING (order_id)
    GROUP BY i.product_id
)
SELECT p.product_id, p.product_name, p.available,
       COALESCE(d.reserved_units, 0) AS reserved_units,
       COALESCE(d.draft_units, 0) AS draft_units,
       GREATEST(COALESCE(d.draft_units, 0) - p.available, 0) AS draft_stock_gap
FROM products AS p
LEFT JOIN demand AS d USING (product_id)
ORDER BY draft_stock_gap DESC, p.product_id;
