-- PASO 1 de la venta distribuida: factura + pago + descuento de stock en UNA transacción ACID
-- Si algo falla (ej. stock insuficiente), se hace ROLLBACK y no queda nada a medias.
\set ON_ERROR_STOP on

BEGIN;

INSERT INTO facturas (numero, cliente_id, canal, subtotal, iva, total)
VALUES ('FAC-2026-0001', 1, 'web', 561.25, 84.19, 645.44);

INSERT INTO factura_items (factura_id, sku, cantidad, precio_unit) VALUES
  (currval('facturas_id_seq'), 'TV-SAMS-55', 1, 549.00),
  (currval('facturas_id_seq'), 'ARROZ-5KG',  1,  12.25);

UPDATE productos_stock SET stock = stock - 1 WHERE sku IN ('TV-SAMS-55', 'ARROZ-5KG');

INSERT INTO pagos (factura_id, metodo, monto)
VALUES (currval('facturas_id_seq'), 'tarjeta', 645.44);

COMMIT;

-- Evidencia (captura 2): SELECT en Postgres
SELECT f.numero, c.nombre AS cliente, f.canal, f.total, p.metodo, f.fecha
FROM facturas f
JOIN clientes c ON c.id = f.cliente_id
JOIN pagos p    ON p.factura_id = f.id
WHERE f.numero = 'FAC-2026-0001';

SELECT sku, stock FROM productos_stock ORDER BY sku;
