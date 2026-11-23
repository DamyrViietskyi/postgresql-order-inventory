# PostgreSQL Order and Inventory Analysis

**SQL · PostgreSQL · psql**

This case models how a shop can reserve stock, confirm an order, and return stock on cancellation. It also reports order value by status and identifies gaps between available stock and draft demand.

## Design

- Reservation locks the order and its product rows in product ID order. An order is reserved only when all items can be fulfilled.
- Confirmation accepts only reserved orders. Cancellation returns stock only when the reserved order transitions to cancelled. Repeated operations leave stock unchanged.
- The example assumes order items remain fixed while an operation runs. The setup enforces one line per product per order.
- Draft stock gaps are a demand indicator. Reserved quantities were already deducted from available stock.

## Run the demo

From the project root, connect to a fresh PostgreSQL database with `psql`:

```sh
createdb inventory_demo
psql -X -v ON_ERROR_STOP=1 -d inventory_demo -f sql/setup.sql
psql -X -v ON_ERROR_STOP=1 -d inventory_demo -f sql/smoke.sql
psql -X -v ON_ERROR_STOP=1 -d inventory_demo -f sql/analytics.sql
```

To run a single operation, pass an order ID with `-v order_id=102`. Apply the smoke script once to a fresh seed. The smoke checks cover state transitions, insufficient stock, and repeated requests in one session.

All demo data is synthetic. The transaction workflow grew out of database coursework at Kyiv School of Economics.
