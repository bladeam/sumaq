-- ==============================================================================
-- BASE DE DATOS: SERVICIOS BÁSICOS CERCADO - COCHABAMBA (MySQL)
-- Descripción: Sistema de gestión de servicios básicos (SEMAPA, ELFEC, YPFB Gas)
-- Ubicación: Municipio de Cercado, Cochabamba, Bolivia
-- ==============================================================================

DROP DATABASE IF EXISTS servicios_cercado_cbba;
CREATE DATABASE servicios_cercado_cbba CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE servicios_cercado_cbba;

-- 1. TABLA: DISTRITOS
CREATE TABLE distritos (
id_distrito INT AUTO_INCREMENT PRIMARY KEY,
numero_distrito INT NOT NULL UNIQUE,
nombre_zona VARCHAR(100) NOT NULL,
subalcaldia VARCHAR(100) NOT NULL
) ENGINE=InnoDB;

-- 2. TABLA: OTBS (Organización Territorial de Base)
CREATE TABLE otbs (
id_otb INT AUTO_INCREMENT PRIMARY KEY,
nombre_otb VARCHAR(120) NOT NULL,
id_distrito INT NOT NULL,
presidente_otb VARCHAR(100),
FOREIGN KEY (id_distrito) REFERENCES distritos(id_distrito) ON DELETE CASCADE
) ENGINE=InnoDB;

-- 3. TABLA: CLIENTES / USUARIOS
CREATE TABLE clientes (
id_cliente INT AUTO_INCREMENT PRIMARY KEY,
ci_nit VARCHAR(20) NOT NULL UNIQUE,
nombres VARCHAR(80) NOT NULL,
apellidos VARCHAR(80) NOT NULL,
telefono VARCHAR(20),
email VARCHAR(100),
direccion_calle VARCHAR(150) NOT NULL,
id_otb INT NOT NULL,
fecha_registro DATE NOT NULL,
FOREIGN KEY (id_otb) REFERENCES otbs(id_otb)
) ENGINE=InnoDB;

-- 4. TABLA: EMPRESAS PROVEEDORAS
CREATE TABLE empresas_servicios (
id_empresa INT AUTO_INCREMENT PRIMARY KEY,
nombre_empresa VARCHAR(80) NOT NULL, -- SEMAPA, ELFEC, YPFB REDES DE GAS
tipo_servicio ENUM('Agua Potable', 'Electricidad', 'Gas Domiciliario', 'Alcantarillado') NOT NULL,
telefono_soporte VARCHAR(20)
) ENGINE=InnoDB;

-- 5. TABLA: CATEGORIAS TARIFARIAS
CREATE TABLE categorias_tarifarias (
id_categoria INT AUTO_INCREMENT PRIMARY KEY,
id_empresa INT NOT NULL,
nombre_categoria VARCHAR(50) NOT NULL, -- Domiciliario, Comercial, Industrial, Social
tarifa_base DECIMAL(10,2) NOT NULL,
costo_unidad DECIMAL(10,2) NOT NULL, -- Costo por m3 o kWh
FOREIGN KEY (id_empresa) REFERENCES empresas_servicios(id_empresa)
) ENGINE=InnoDB;

-- 6. TABLA: MEDIDORES / PUNTOS DE SUMINISTRO
CREATE TABLE medidores (
id_medidor INT AUTO_INCREMENT PRIMARY KEY,
numero_serie VARCHAR(50) NOT NULL UNIQUE,
id_cliente INT NOT NULL,
id_categoria INT NOT NULL,
ubicacion_coordenadas VARCHAR(50),
estado ENUM('Activo', 'Suspendido', 'Retirado') DEFAULT 'Activo',
fecha_instalacion DATE NOT NULL,
FOREIGN KEY (id_cliente) REFERENCES clientes(id_cliente) ON DELETE CASCADE,
FOREIGN KEY (id_categoria) REFERENCES categorias_tarifarias(id_categoria)
) ENGINE=InnoDB;

-- 7. TABLA: LECTURAS DE CONSUMO
CREATE TABLE lecturas (
id_lectura INT AUTO_INCREMENT PRIMARY KEY,
id_medidor INT NOT NULL,
gestion_mes INT NOT NULL, -- 1 al 12
gestion_anio INT NOT NULL, -- ej. 2024
lectura_anterior DECIMAL(10,2) NOT NULL,
lectura_actual DECIMAL(10,2) NOT NULL,
consumo_calculado DECIMAL(10,2) GENERATED ALWAYS AS (lectura_actual - lectura_anterior) STORED,
fecha_lectura DATE NOT NULL,
FOREIGN KEY (id_medidor) REFERENCES medidores(id_medidor)
) ENGINE=InnoDB;

-- 8. TABLA: FACTURAS
CREATE TABLE facturas (
id_factura INT AUTO_INCREMENT PRIMARY KEY,
numero_factura VARCHAR(30) NOT NULL UNIQUE,
id_lectura INT NOT NULL,
monto_total DECIMAL(10,2) NOT NULL,
fecha_emision DATE NOT NULL,
fecha_vencimiento DATE NOT NULL,
estado_pago ENUM('Pendiente', 'Pagado', 'Vencido') DEFAULT 'Pendiente',
FOREIGN KEY (id_lectura) REFERENCES lecturas(id_lectura)
) ENGINE=InnoDB;

-- 9. TABLA: PAGOS
CREATE TABLE pagos (
id_pago INT AUTO_INCREMENT PRIMARY KEY,
id_factura INT NOT NULL,
fecha_pago DATETIME NOT NULL,
monto_pagado DECIMAL(10,2) NOT NULL,
metodo_pago ENUM('Efectivo', 'QR / Transferencia', 'Caja Banco', 'Debito Automatico') NOT NULL,
cajero_atencion VARCHAR(50),
FOREIGN KEY (id_factura) REFERENCES facturas(id_factura)
) ENGINE=InnoDB;

-- 10. TABLA: RECLAMOS Y AVERIAS
CREATE TABLE reclamos (
id_reclamo INT AUTO_INCREMENT PRIMARY KEY,
codigo_ticket VARCHAR(20) NOT NULL UNIQUE,
id_cliente INT NOT NULL,
id_empresa INT NOT NULL,
tipo_reclamo VARCHAR(100) NOT NULL, -- Fuga de agua, Corte de energia, Sobrecargo
descripcion TEXT,
fecha_reclamo DATETIME NOT NULL,
estado_reclamo ENUM('Pendiente', 'En Proceso', 'Resuelto', 'Rechazado') DEFAULT 'Pendiente',
FOREIGN KEY (id_cliente) REFERENCES clientes(id_cliente),
FOREIGN KEY (id_empresa) REFERENCES empresas_servicios(id_empresa)
) ENGINE=InnoDB;

-- ==============================================================================
-- INSERCIÓN DE DATOS SIMULADOS (100 A 200 REGISTROS POR TABLA)
-- ==============================================================================

-- 1. DISTRITOS (15 distritos de Cercado)
INSERT INTO distritos (numero_distrito, nombre_zona, subalcaldia) VALUES
(1, 'Zona Queru Queru / Tupuraya', 'Subalcaldía Tunari'),
(2, 'Zona Cala Cala / Sarco', 'Subalcaldía Tunari'),
(3, 'Zona Sarco / Chimba', 'Subalcaldía Molle'),
(4, 'Zona La Chimba / Coña Coña', 'Subalcaldía Molle'),
(5, 'Zona Jaihuayco / Alalay Norte', 'Subalcaldía Alejo Calatayud'),
(6, 'Zona San José de la Banda', 'Subalcaldía Valle Hermoso'),
(7, 'Zona Valle Hermoso', 'Subalcaldía Valle Hermoso'),
(8, 'Zona Uspha Uspha', 'Subalcaldía Valle Hermoso'),
(9, 'Zona Pucara / Arrumani', 'Subalcaldía Itocta'),
(10, 'Zona Casco Viejo / Central', 'Subalcaldía Adela Zamudio'),
(11, 'Zona Las Cuadras / Muyurina', 'Subalcaldía Adela Zamudio'),
(12, 'Zona Hipódromo / Tupuraya', 'Subalcaldía Adela Zamudio'),
(13, 'Zona Taquiña / Pacata', 'Subalcaldía Tunari'),
(14, 'Zona la Maica / Pucaritani', 'Subalcaldía Itocta'),
(15, 'Zona Khora / Tamborada', 'Subalcaldía Itocta');

-- 2. OTBS (100 OTBs)
DELIMITER //
CREATE PROCEDURE CargarOTBs()
BEGIN
DECLARE i INT DEFAULT 1;
WHILE i <= 100 DO
INSERT INTO otbs (nombre_otb, id_distrito, presidente_otb)
VALUES (
CONCAT('OTB ', CASE (i % 10)
WHEN 0 THEN 'Las Cuadras ' WHEN 1 THEN 'Cala Cala ' WHEN 2 THEN 'Jaihuayco '
WHEN 3 THEN 'Aroma ' WHEN 4 THEN 'Sarzani ' WHEN 5 THEN 'Tupuraya '
WHEN 6 THEN 'Pacata ' WHEN 7 THEN 'Temporal ' WHEN 8 THEN 'Loreto ' ELSE 'Chimaco ' END, i),
((i % 15) + 1),
CONCAT('Presidente ', i)
);
SET i = i + 1;
END WHILE;
END //
DELIMITER ;
CALL CargarOTBs();
DROP PROCEDURE CargarOTBs;

-- 3. CLIENTES (120 Registros)
DELIMITER //
CREATE PROCEDURE CargarClientes()
BEGIN
DECLARE i INT DEFAULT 1;
WHILE i <= 120 DO
INSERT INTO clientes (ci_nit, nombres, apellidos, telefono, email, direccion_calle, id_otb, fecha_registro)
VALUES (
CONCAT(3000000 + (i * 1234), '-1B'),
CONCAT('Nombre_', i),
CONCAT('Apellido_', i),
CONCAT('44', FLOOR(100000 + RAND() * 899999)),
CONCAT('usuario', i, '@gmail.com'),
CONCAT('Av. Heroínas #', 100 + i),
((i % 100) + 1),
DATE_SUB(CURDATE(), INTERVAL (i * 10) DAY)
);
SET i = i + 1;
END WHILE;
END //
DELIMITER ;
CALL CargarClientes();
DROP PROCEDURE CargarClientes;

-- 4. EMPRESAS DE SERVICIOS (3 Empresas principales)
INSERT INTO empresas_servicios (nombre_empresa, tipo_servicio, telefono_soporte) VALUES
('SEMAPA', 'Agua Potable', '44252222'),
('ELFEC S.A.', 'Electricidad', '44258888'),
('YPFB Redes de Gas', 'Gas Domiciliario', '800109732');

-- 5. CATEGORIAS TARIFARIAS
INSERT INTO categorias_tarifarias (id_empresa, nombre_categoria, tarifa_base, costo_unidad) VALUES
(1, 'Domiciliario Social', 12.00, 2.50),
(1, 'Domiciliario General', 25.00, 4.20),
(1, 'Comercial', 50.00, 7.80),
(2, 'Residencial Pequeño Demandante', 15.00, 0.78),
(2, 'General Comercial', 40.00, 1.20),
(2, 'Industrial', 120.00, 0.95),
(3, 'Domiciliario Fijo', 8.00, 1.50),
(3, 'Comercial Gas', 20.00, 2.80);

-- 6. MEDIDORES (120 Medidores)
DELIMITER //
CREATE PROCEDURE CargarMedidores()
BEGIN
DECLARE i INT DEFAULT 1;
WHILE i <= 120 DO
INSERT INTO medidores (numero_serie, id_cliente, id_categoria, ubicacion_coordenadas, estado, fecha_instalacion)
VALUES (
CONCAT('MED-CBBA-', 1000 + i),
i,
((i % 8) + 1),
CONCAT('-17.38', i, ', -66.15', i),
IF(i % 12 = 0, 'Suspendido', 'Activo'),
DATE_SUB(CURDATE(), INTERVAL (i * 15) DAY)
);
SET i = i + 1;
END WHILE;
END //
DELIMITER ;
CALL CargarMedidores();
DROP PROCEDURE CargarMedidores;

-- 7. LECTURAS (120 Lecturas)
DELIMITER //
CREATE PROCEDURE CargarLecturas()
BEGIN
DECLARE i INT DEFAULT 1;
DECLARE ant INT;
DECLARE act INT;
WHILE i <= 120 DO
SET ant = FLOOR(100 + RAND() * 500);
SET act = ant + FLOOR(20 + RAND() * 150);
INSERT INTO lecturas (id_medidor, gestion_mes, gestion_anio, lectura_anterior, lectura_actual, fecha_lectura)
VALUES (
i,
((i % 12) + 1),
2024,
ant,
act,
DATE_SUB(CURDATE(), INTERVAL (i * 2) DAY)
);
SET i = i + 1;
END WHILE;
END //
DELIMITER ;
CALL CargarLecturas();
DROP PROCEDURE CargarLecturas;

-- 8. FACTURAS (120 Facturas)
DELIMITER //
CREATE PROCEDURE CargarFacturas()
BEGIN
DECLARE i INT DEFAULT 1;
WHILE i <= 120 DO
INSERT INTO facturas (numero_factura, id_lectura, monto_total, fecha_emision, fecha_vencimiento, estado_pago)
VALUES (
CONCAT('FAC-2024-', 5000 + i),
i,
ROUND(50 + (RAND() * 350), 2),
DATE_SUB(CURDATE(), INTERVAL (i + 5) DAY),
DATE_ADD(CURDATE(), INTERVAL (30 - i) DAY),
IF(i % 3 = 0, 'Pendiente', 'Pagado')
);
SET i = i + 1;
END WHILE;
END //
DELIMITER ;
CALL CargarFacturas();
DROP PROCEDURE CargarFacturas;

-- 9. PAGOS (100 Pagos registrados)
DELIMITER //
CREATE PROCEDURE CargarPagos()
BEGIN
DECLARE i INT DEFAULT 1;
WHILE i <= 100 DO
INSERT INTO pagos (id_factura, fecha_pago, monto_pagado, metodo_pago, cajero_atencion)
VALUES (
i,
NOW(),
150.50 + (i * 2),
CASE (i % 4) WHEN 0 THEN 'Efectivo' WHEN 1 THEN 'QR / Transferencia' WHEN 2 THEN 'Caja Banco' ELSE 'Debito Automatico' END,
CONCAT('Cajero_', (i % 5) + 1)
);
SET i = i + 1;
END WHILE;
END //
DELIMITER ;
CALL CargarPagos();
DROP PROCEDURE CargarPagos;

-- 10. RECLAMOS (100 Reclamos)
DELIMITER //
CREATE PROCEDURE CargarReclamos()
BEGIN
DECLARE i INT DEFAULT 1;
WHILE i <= 100 DO
INSERT INTO reclamos (codigo_ticket, id_cliente, id_empresa, tipo_reclamo, descripcion, fecha_reclamo, estado_reclamo)
VALUES (
CONCAT('TK-', 8000 + i),
i,
((i % 3) + 1),
CASE (i % 4) WHEN 0 THEN 'Fuga de agua en vía pública' WHEN 1 THEN 'Baja tensión / Corte eléctrico' WHEN 2 THEN 'Falta de presión de gas' ELSE 'Cobro excesivo en factura' END,
CONCAT('Atención requerida para el reclamo número ', i, ' reportado en Cercado.'),
DATE_SUB(CURDATE(), INTERVAL i DAY),
CASE (i % 4) WHEN 0 THEN 'Pendiente' WHEN 1 THEN 'En Proceso' WHEN 2 THEN 'Resuelto' ELSE 'Rechazado' END
);
SET i = i + 1;
END WHILE;
END //
DELIMITER ;
CALL CargarReclamos();
DROP PROCEDURE CargarReclamos;
