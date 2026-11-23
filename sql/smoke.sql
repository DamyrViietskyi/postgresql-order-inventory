\set ON_ERROR_STOP on
\set order_id 101
\ir reserve.sql
\ir confirm.sql
\ir cancel.sql
DO $$
BEGIN
    IF (SELECT status FROM orders WHERE order_id = 101) <> 'draft'
       OR (SELECT available FROM products WHERE product_id = 1) <> 5
       OR (SELECT available FROM products WHERE product_id = 2) <> 1 THEN
        RAISE EXCEPTION 'Insufficient stock or draft transition was accepted';
    END IF;
END $$;

\set order_id 102
\ir reserve.sql
\ir reserve.sql
\set order_id 103
\ir reserve.sql
DO $$
BEGIN
    IF (SELECT status FROM orders WHERE order_id = 102) <> 'reserved'
       OR (SELECT status FROM orders WHERE order_id = 103) <> 'draft'
       OR (SELECT available FROM products WHERE product_id = 1) <> 2
       OR (SELECT available FROM products WHERE product_id = 2) <> 0 THEN
        RAISE EXCEPTION 'Reservation or repeated reservation failed';
    END IF;
END $$;

\set order_id 102
\ir cancel.sql
\ir cancel.sql
\set order_id 104
\ir reserve.sql
\ir confirm.sql
\ir confirm.sql
\ir cancel.sql
DO $$
BEGIN
    IF (SELECT status FROM orders WHERE order_id = 102) <> 'cancelled'
       OR (SELECT status FROM orders WHERE order_id = 104) <> 'confirmed'
       OR (SELECT available FROM products WHERE product_id = 1) <> 5
       OR (SELECT available FROM products WHERE product_id = 2) <> 1
       OR (SELECT available FROM products WHERE product_id = 3) <> 2 THEN
        RAISE EXCEPTION 'Cancel or confirm changed inventory incorrectly';
    END IF;
END $$;
