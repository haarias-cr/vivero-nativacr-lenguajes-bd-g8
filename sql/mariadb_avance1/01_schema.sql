-- Vivero NativaCR - Grupo 8
-- Esquema relacional (8 tablas)

DROP DATABASE IF EXISTS vivero_nativacr;
CREATE DATABASE vivero_nativacr
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

USE vivero_nativacr;

CREATE TABLE zonas_biologicas (
  id_zona        INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  nombre         VARCHAR(80)  NOT NULL UNIQUE,
  descripcion    VARCHAR(255) NULL
) ENGINE=InnoDB;

CREATE TABLE especies (
  id_especie           INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  id_zona              INT UNSIGNED NOT NULL,
  nombre_cientifico    VARCHAR(120) NOT NULL,
  nombre_comun         VARCHAR(80)  NOT NULL,
  precio_unitario      DECIMAL(10,2) NOT NULL CHECK (precio_unitario >= 0),
  descripcion          TEXT NULL,
  CONSTRAINT fk_especies_zona
    FOREIGN KEY (id_zona) REFERENCES zonas_biologicas(id_zona)
) ENGINE=InnoDB;

CREATE TABLE invernaderos (
  id_invernadero INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  nombre         VARCHAR(60)  NOT NULL UNIQUE,
  ubicacion      VARCHAR(120) NOT NULL,
  capacidad      INT UNSIGNED NOT NULL CHECK (capacidad > 0)
) ENGINE=InnoDB;

CREATE TABLE lotes (
  id_lote        INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  id_especie     INT UNSIGNED NOT NULL,
  id_invernadero INT UNSIGNED NOT NULL,
  cantidad       INT UNSIGNED NOT NULL CHECK (cantidad >= 0),
  fecha_siembra  DATE         NOT NULL,
  estado         ENUM('activo','vendido','descartado') NOT NULL DEFAULT 'activo',
  CONSTRAINT fk_lotes_especie
    FOREIGN KEY (id_especie) REFERENCES especies(id_especie),
  CONSTRAINT fk_lotes_invernadero
    FOREIGN KEY (id_invernadero) REFERENCES invernaderos(id_invernadero)
) ENGINE=InnoDB;

CREATE TABLE clientes (
  id_cliente INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  nombre     VARCHAR(100) NOT NULL,
  telefono   VARCHAR(20)  NULL,
  correo     VARCHAR(120) NULL,
  tipo       ENUM('persona','institucion') NOT NULL DEFAULT 'persona'
) ENGINE=InnoDB;

CREATE TABLE pedidos (
  id_pedido    INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  id_cliente   INT UNSIGNED NOT NULL,
  fecha_pedido DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  estado       ENUM('pendiente','confirmado','entregado','cancelado') NOT NULL DEFAULT 'pendiente',
  total        DECIMAL(12,2) NOT NULL DEFAULT 0 CHECK (total >= 0),
  CONSTRAINT fk_pedidos_cliente
    FOREIGN KEY (id_cliente) REFERENCES clientes(id_cliente)
) ENGINE=InnoDB;

CREATE TABLE detalle_pedido (
  id_detalle  INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  id_pedido   INT UNSIGNED NOT NULL,
  id_lote     INT UNSIGNED NOT NULL,
  cantidad    INT UNSIGNED NOT NULL CHECK (cantidad > 0),
  subtotal    DECIMAL(12,2) NOT NULL CHECK (subtotal >= 0),
  CONSTRAINT fk_detalle_pedido
    FOREIGN KEY (id_pedido) REFERENCES pedidos(id_pedido),
  CONSTRAINT fk_detalle_lote
    FOREIGN KEY (id_lote) REFERENCES lotes(id_lote),
  CONSTRAINT uq_pedido_lote UNIQUE (id_pedido, id_lote)
) ENGINE=InnoDB;

CREATE TABLE cuidados_lote (
  id_cuidado      INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  id_lote         INT UNSIGNED NOT NULL,
  fecha_cuidado   DATE         NOT NULL,
  tipo_cuidado    ENUM('riego','fertilizacion','poda','control_plagas','trasplante') NOT NULL,
  observaciones   VARCHAR(255) NULL,
  CONSTRAINT fk_cuidados_lote
    FOREIGN KEY (id_lote) REFERENCES lotes(id_lote)
) ENGINE=InnoDB;

CREATE INDEX idx_lotes_estado ON lotes(estado);
CREATE INDEX idx_pedidos_fecha ON pedidos(fecha_pedido);
CREATE INDEX idx_especies_comun ON especies(nombre_comun);
