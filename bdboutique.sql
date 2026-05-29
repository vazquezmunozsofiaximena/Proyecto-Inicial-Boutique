-- ============================================================
--  Base de datos: bdboutique
--  Descripción:   Sistema de gestión para tienda boutique
--  Motor:         MySQL 8.0+
--  Fecha:         2026-05-11
-- ============================================================

CREATE DATABASE IF NOT EXISTS bdboutique
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

USE bdboutique;

-- ------------------------------------------------------------
-- 1. CATEGORIA
-- ------------------------------------------------------------
CREATE TABLE categoria (
    id_categoria   INT            NOT NULL AUTO_INCREMENT,
    nombre         VARCHAR(80)    NOT NULL,
    descripcion    TEXT,
    CONSTRAINT pk_categoria PRIMARY KEY (id_categoria),
    CONSTRAINT uq_categoria_nombre UNIQUE (nombre)
);

-- ------------------------------------------------------------
-- 2. PROVEEDOR
-- ------------------------------------------------------------
CREATE TABLE proveedor (
    id_proveedor   INT            NOT NULL AUTO_INCREMENT,
    nombre         VARCHAR(120)   NOT NULL,
    contacto       VARCHAR(100),
    telefono       VARCHAR(20),
    email          VARCHAR(120),
    pais           VARCHAR(60),
    CONSTRAINT pk_proveedor PRIMARY KEY (id_proveedor)
);

-- ------------------------------------------------------------
-- 3. PRODUCTO
-- ------------------------------------------------------------
CREATE TABLE producto (
    id_producto    INT            NOT NULL AUTO_INCREMENT,
    nombre         VARCHAR(120)   NOT NULL,
    descripcion    TEXT,
    precio         DECIMAL(10,2)  NOT NULL,
    stock          INT            NOT NULL DEFAULT 0,
    id_categoria   INT            NOT NULL,
    id_proveedor   INT            NOT NULL,
    CONSTRAINT pk_producto       PRIMARY KEY (id_producto),
    CONSTRAINT fk_prod_categoria FOREIGN KEY (id_categoria)
        REFERENCES categoria (id_categoria)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_prod_proveedor FOREIGN KEY (id_proveedor)
        REFERENCES proveedor (id_proveedor)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT chk_precio  CHECK (precio  >= 0),
    CONSTRAINT chk_stock   CHECK (stock   >= 0)
);

-- ------------------------------------------------------------
-- 4. CLIENTE
-- ------------------------------------------------------------
CREATE TABLE cliente (
    id_cliente      INT            NOT NULL AUTO_INCREMENT,
    nombre          VARCHAR(80)    NOT NULL,
    apellido        VARCHAR(80)    NOT NULL,
    email           VARCHAR(120)   NOT NULL,
    telefono        VARCHAR(20),
    direccion       TEXT,
    fecha_registro  DATE           NOT NULL DEFAULT (CURRENT_DATE),
    CONSTRAINT pk_cliente      PRIMARY KEY (id_cliente),
    CONSTRAINT uq_cliente_email UNIQUE (email)
);

-- ------------------------------------------------------------
-- 5. EMPLEADO
-- ------------------------------------------------------------
CREATE TABLE empleado (
    id_empleado    INT            NOT NULL AUTO_INCREMENT,
    nombre         VARCHAR(80)    NOT NULL,
    apellido       VARCHAR(80)    NOT NULL,
    cargo          VARCHAR(60)    NOT NULL,
    email          VARCHAR(120)   NOT NULL,
    telefono       VARCHAR(20),
    fecha_alta     DATE           NOT NULL DEFAULT (CURRENT_DATE),
    CONSTRAINT pk_empleado      PRIMARY KEY (id_empleado),
    CONSTRAINT uq_empleado_email UNIQUE (email)
);

-- ------------------------------------------------------------
-- 6. PEDIDO
-- ------------------------------------------------------------
CREATE TABLE pedido (
    id_pedido      INT            NOT NULL AUTO_INCREMENT,
    fecha          DATETIME       NOT NULL DEFAULT CURRENT_TIMESTAMP,
    estado         ENUM('pendiente','confirmado','enviado',
                        'entregado','cancelado')
                                  NOT NULL DEFAULT 'pendiente',
    total          DECIMAL(10,2)  NOT NULL DEFAULT 0.00,
    notas          TEXT,
    id_cliente     INT            NOT NULL,
    id_empleado    INT,
    CONSTRAINT pk_pedido         PRIMARY KEY (id_pedido),
    CONSTRAINT fk_ped_cliente    FOREIGN KEY (id_cliente)
        REFERENCES cliente (id_cliente)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_ped_empleado   FOREIGN KEY (id_empleado)
        REFERENCES empleado (id_empleado)
        ON UPDATE CASCADE ON DELETE SET NULL,
    CONSTRAINT chk_total         CHECK (total >= 0)
);

-- ------------------------------------------------------------
-- 7. DETALLE_PEDIDO
-- ------------------------------------------------------------
CREATE TABLE detalle_pedido (
    id_detalle      INT            NOT NULL AUTO_INCREMENT,
    id_pedido       INT            NOT NULL,
    id_producto     INT            NOT NULL,
    cantidad        INT            NOT NULL,
    precio_unitario DECIMAL(10,2)  NOT NULL,
    descuento       DECIMAL(5,2)            DEFAULT 0.00,
    CONSTRAINT pk_detalle        PRIMARY KEY (id_detalle),
    CONSTRAINT fk_det_pedido     FOREIGN KEY (id_pedido)
        REFERENCES pedido (id_pedido)
        ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT fk_det_producto   FOREIGN KEY (id_producto)
        REFERENCES producto (id_producto)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT chk_cantidad      CHECK (cantidad        > 0),
    CONSTRAINT chk_pu            CHECK (precio_unitario >= 0),
    CONSTRAINT chk_descuento     CHECK (descuento BETWEEN 0 AND 100)
);

-- ------------------------------------------------------------
-- 8. PAGO
-- ------------------------------------------------------------
CREATE TABLE pago (
    id_pago        INT            NOT NULL AUTO_INCREMENT,
    id_pedido      INT            NOT NULL,
    fecha          DATETIME       NOT NULL DEFAULT CURRENT_TIMESTAMP,
    monto          DECIMAL(10,2)  NOT NULL,
    metodo         ENUM('efectivo','tarjeta_debito','tarjeta_credito',
                        'transferencia','voucher')
                                  NOT NULL,
    referencia     VARCHAR(100),
    CONSTRAINT pk_pago           PRIMARY KEY (id_pago),
    CONSTRAINT fk_pago_pedido    FOREIGN KEY (id_pedido)
        REFERENCES pedido (id_pedido)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT chk_monto         CHECK (monto > 0)
);

-- ============================================================
--  ÍNDICES ADICIONALES (mejoran consultas frecuentes)
-- ============================================================
CREATE INDEX idx_producto_categoria ON producto (id_categoria);
CREATE INDEX idx_producto_proveedor ON producto (id_proveedor);
CREATE INDEX idx_pedido_cliente     ON pedido    (id_cliente);
CREATE INDEX idx_pedido_estado      ON pedido    (estado);
CREATE INDEX idx_detalle_pedido     ON detalle_pedido (id_pedido);
CREATE INDEX idx_detalle_producto   ON detalle_pedido (id_producto);
CREATE INDEX idx_pago_pedido        ON pago      (id_pedido);

-- ============================================================
--  DATOS DE PRUEBA
-- ============================================================

-- Categorías
INSERT INTO categoria (nombre, descripcion) VALUES
    ('Vestidos',    'Vestidos de día, noche y ocasión especial'),
    ('Blusas',      'Blusas casuales y formales'),
    ('Pantalones',  'Pantalones y joggers'),
    ('Accesorios',  'Bolsos, cinturones y joyería'),
    ('Calzado',     'Zapatos, sandalias y botines');

-- Proveedores
INSERT INTO proveedor (nombre, contacto, telefono, email, pais) VALUES
    ('Moda MX S.A.',      'Laura Vega',    '5551234567', 'ventas@modamx.com',    'México'),
    ('Textiles Sur',      'Carlos Ríos',   '5559876543', 'csur@textiles.com',    'México'),
    ('Fashion Import',    'Ana Blanco',    '5554561230', 'ana@fashionimp.com',   'Colombia');

-- Productos
INSERT INTO producto (nombre, descripcion, precio, stock, id_categoria, id_proveedor) VALUES
    ('Vestido floral midi',    'Vestido estampado flores, tela ligera',  899.00,  15, 1, 1),
    ('Blusa de seda off-shoulder', 'Blusa elegante para ocasión',        650.00,  20, 2, 1),
    ('Pantalón de lino beige', 'Pantalón holgado ideal para verano',     750.00,  18, 3, 2),
    ('Bolso de piel sintética','Bolso mediano con correa ajustable',     1200.00, 10, 4, 3),
    ('Sandalia plana dorada',  'Sandalia con detalle metálico',          580.00,  25, 5, 3);

-- Empleados
INSERT INTO empleado (nombre, apellido, cargo, email, telefono, fecha_alta) VALUES
    ('Sofía',    'Martínez', 'Vendedora',  'sofia@boutique.com',  '6561112233', '2024-01-15'),
    ('Patricia', 'Herrera',  'Encargada',  'paty@boutique.com',   '6564445566', '2023-06-01');

-- Clientes
INSERT INTO cliente (nombre, apellido, email, telefono, direccion, fecha_registro) VALUES
    ('María',     'López',    'mlopez@email.com',  '6561234567', 'Av. Juárez 100, Col. Centro', '2025-03-10'),
    ('Fernanda',  'Torres',   'ftorres@email.com', '6569876543', 'Blvd. Independencia 45',      '2025-07-22'),
    ('Claudia',   'Ruiz',     'cruiz@email.com',   '6562223344', 'Calle Reforma 200, Depto 3',  '2026-01-05');

-- Pedidos
INSERT INTO pedido (fecha, estado, total, id_cliente, id_empleado) VALUES
    ('2026-04-10 10:30:00', 'entregado', 1549.00, 1, 1),
    ('2026-04-18 14:00:00', 'enviado',   1200.00, 2, 2),
    ('2026-05-02 11:15:00', 'pendiente',  650.00, 3, 1);

-- Detalle de pedidos
INSERT INTO detalle_pedido (id_pedido, id_producto, cantidad, precio_unitario, descuento) VALUES
    (1, 1, 1, 899.00,  0.00),
    (1, 5, 1, 580.00,  5.00),
    (2, 4, 1, 1200.00, 0.00),
    (3, 2, 1, 650.00,  0.00);

-- Pagos
INSERT INTO pago (id_pedido, fecha, monto, metodo, referencia) VALUES
    (1, '2026-04-10 10:35:00', 1549.00, 'tarjeta_credito', 'TXN-20260410-001'),
    (2, '2026-04-18 14:05:00', 1200.00, 'transferencia',   'REF-20260418-045'),
    (3, '2026-05-02 11:20:00',  650.00, 'efectivo',        NULL);

-- ============================================================
--  FIN DEL SCRIPT
-- ============================================================
