-- Esquema transaccional (ACID) de Distribuidora Valle Express
-- Reemplaza la tabla monolítica ventas_todo por tablas normalizadas

-- 1. Clientes
CREATE TABLE IF NOT EXISTS clientes (
    id      SERIAL PRIMARY KEY,
    cedula  VARCHAR(13) UNIQUE NOT NULL,
    nombre  VARCHAR(100) NOT NULL,
    email   VARCHAR(100)
);

-- 2. Productos con su stock contable (nunca negativo)
CREATE TABLE IF NOT EXISTS productos_stock (
    sku     VARCHAR(20) PRIMARY KEY,
    nombre  VARCHAR(100) NOT NULL,
    precio  NUMERIC(10,2) NOT NULL CHECK (precio >= 0),
    stock   INT NOT NULL CHECK (stock >= 0)
);

-- 3. Facturas (cada una pertenece a un cliente)
CREATE TABLE IF NOT EXISTS facturas (
    id          SERIAL PRIMARY KEY,
    numero      VARCHAR(20) UNIQUE NOT NULL,
    cliente_id  INT NOT NULL REFERENCES clientes(id),
    canal       VARCHAR(20) NOT NULL,
    fecha       TIMESTAMPTZ NOT NULL DEFAULT now(),
    subtotal    NUMERIC(10,2) NOT NULL,
    iva         NUMERIC(10,2) NOT NULL,
    total       NUMERIC(10,2) NOT NULL
);

-- 4. Detalle de cada factura
CREATE TABLE IF NOT EXISTS factura_items (
    factura_id   INT NOT NULL REFERENCES facturas(id),
    sku          VARCHAR(20) NOT NULL REFERENCES productos_stock(sku),
    cantidad     INT NOT NULL CHECK (cantidad > 0),
    precio_unit  NUMERIC(10,2) NOT NULL,
    PRIMARY KEY (factura_id, sku)
);

-- 5. Pagos (no puede existir un pago sin factura)
CREATE TABLE IF NOT EXISTS pagos (
    id          SERIAL PRIMARY KEY,
    factura_id  INT NOT NULL REFERENCES facturas(id),
    metodo      VARCHAR(20) NOT NULL,
    monto       NUMERIC(10,2) NOT NULL,
    fecha       TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- Datos iniciales
INSERT INTO clientes (cedula, nombre, email) VALUES
  ('1712345678', 'María Pérez', 'maria.perez@mail.com'),
  ('1798765432', 'Carlos Andrade', 'carlos.andrade@mail.com')
ON CONFLICT (cedula) DO NOTHING;

INSERT INTO productos_stock (sku, nombre, precio, stock) VALUES
  ('TV-SAMS-55',  'Televisor Samsung 55" 4K',  549.00, 15),
  ('ARROZ-5KG',   'Arroz Superior 5 kg',        12.25, 200),
  ('REFRI-LG-14', 'Refrigeradora LG 14 pies',  789.90, 8)
ON CONFLICT (sku) DO NOTHING;

-- Listar las tablas creadas
\dt