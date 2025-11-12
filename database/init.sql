-- Script SQL para inicializar la base de datos de Nail Studio
-- Ejecutar en MySQL para crear la estructura necesaria

-- Crear base de datos
CREATE DATABASE IF NOT EXISTS nailstudio CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- Usar la base de datos
USE nailstudio;

-- Crear usuario para la aplicación
CREATE USER IF NOT EXISTS 'nailstudio_user'@'%' IDENTIFIED BY 'nailstudio_pass';
GRANT ALL PRIVILEGES ON nailstudio.* TO 'nailstudio_user'@'%';
FLUSH PRIVILEGES;

-- Tabla de usuarios
CREATE TABLE IF NOT EXISTS usuarios (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(50) NOT NULL,
    apellido VARCHAR(50) NOT NULL,
    celular VARCHAR(20) NOT NULL UNIQUE,
    usuario VARCHAR(50) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    fecha_registro TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    fecha_actualizacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    activo BOOLEAN DEFAULT TRUE,
    INDEX idx_usuario (usuario),
    INDEX idx_celular (celular)
);

-- Tabla de turnos
CREATE TABLE IF NOT EXISTS turnos (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    telefono VARCHAR(20) NOT NULL,
    email VARCHAR(100),
    edad INT,
    servicio ENUM('manicura', 'pedicura', 'nailart', 'gel') NOT NULL,
    fecha DATE NOT NULL,
    hora TIME NOT NULL,
    manos_pies BOOLEAN DEFAULT FALSE,
    diseño_especial BOOLEAN DEFAULT FALSE,
    primera_vez BOOLEAN DEFAULT FALSE,
    comentarios TEXT,
    precio DECIMAL(10,2) NOT NULL,
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    fecha_actualizacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    estado ENUM('pendiente', 'confirmado', 'cancelado', 'completado') DEFAULT 'pendiente',
    INDEX idx_fecha (fecha),
    INDEX idx_estado (estado),
    INDEX idx_servicio (servicio)
);

-- Tabla de servicios (catálogo)
CREATE TABLE IF NOT EXISTS servicios (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(50) NOT NULL,
    descripcion TEXT,
    precio DECIMAL(10,2) NOT NULL,
    duracion_minutos INT DEFAULT 60,
    activo BOOLEAN DEFAULT TRUE,
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Insertar servicios por defecto
INSERT INTO servicios (nombre, descripcion, precio, duracion_minutos) VALUES
('manicura', 'Cuidado completo de las uñas de las manos con técnicas profesionales', 25000, 60),
('pedicura', 'Tratamiento completo para pies y uñas con relajación incluida', 30000, 90),
('nailart', 'Diseños únicos y personalizados para ocasiones especiales', 35000, 120),
('gel', 'Extensiones y fortalecimiento con productos de alta calidad', 40000, 90);

-- Tabla de horarios disponibles
CREATE TABLE IF NOT EXISTS horarios_disponibles (
    id INT AUTO_INCREMENT PRIMARY KEY,
    dia_semana ENUM('lunes', 'martes', 'miercoles', 'jueves', 'viernes', 'sabado', 'domingo') NOT NULL,
    hora_inicio TIME NOT NULL,
    hora_fin TIME NOT NULL,
    activo BOOLEAN DEFAULT TRUE,
    INDEX idx_dia_hora (dia_semana, hora_inicio)
);

-- Insertar horarios por defecto
INSERT INTO horarios_disponibles (dia_semana, hora_inicio, hora_fin) VALUES
('lunes', '09:00:00', '19:00:00'),
('martes', '09:00:00', '19:00:00'),
('miercoles', '09:00:00', '19:00:00'),
('jueves', '09:00:00', '19:00:00'),
('viernes', '09:00:00', '19:00:00'),
('sabado', '09:00:00', '17:00:00');

-- Tabla de configuración
CREATE TABLE IF NOT EXISTS configuracion (
    id INT AUTO_INCREMENT PRIMARY KEY,
    clave VARCHAR(50) NOT NULL UNIQUE,
    valor TEXT,
    descripcion VARCHAR(200),
    fecha_actualizacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Insertar configuración por defecto
INSERT INTO configuracion (clave, valor, descripcion) VALUES
('telefono_contacto', '+57 300 123 4567', 'Teléfono de contacto principal'),
('email_contacto', 'info@nailstudio.com', 'Email de contacto principal'),
('direccion', 'Calle 123 #45-67, Bogotá', 'Dirección del salón'),
('descuento_manos_pies', '10', 'Porcentaje de descuento para manicura + pedicura'),
('tiempo_anticipacion_cancelacion', '24', 'Horas de anticipación para cancelar turno'),
('mensaje_bienvenida', '¡Bienvenida a Nail Studio!', 'Mensaje de bienvenida');

-- Vista para turnos con información completa
CREATE VIEW vista_turnos_completos AS
SELECT 
    t.id,
    t.nombre,
    t.telefono,
    t.email,
    t.edad,
    s.nombre as servicio_nombre,
    s.descripcion as servicio_descripcion,
    t.fecha,
    t.hora,
    t.manos_pies,
    t.diseño_especial,
    t.primera_vez,
    t.comentarios,
    t.precio,
    t.fecha_creacion,
    t.estado,
    CASE 
        WHEN t.manos_pies = 1 THEN CONCAT(s.nombre, ' + Pedicura')
        ELSE s.nombre
    END as servicio_completo
FROM turnos t
LEFT JOIN servicios s ON t.servicio = s.nombre;

-- Procedimiento para obtener turnos disponibles en una fecha
DELIMITER //
CREATE PROCEDURE GetAvailableSlots(IN fecha_param DATE)
BEGIN
    DECLARE dia_semana VARCHAR(20);
    
    -- Obtener día de la semana
    SET dia_semana = LOWER(DAYNAME(fecha_param));
    
    -- Si es domingo, no hay horarios
    IF dia_semana = 'sunday' THEN
        SELECT 'No hay horarios disponibles los domingos' as mensaje;
    ELSE
        -- Mostrar horarios disponibles para el día
        SELECT 
            h.hora_inicio,
            h.hora_fin,
            CASE 
                WHEN EXISTS (
                    SELECT 1 FROM turnos t 
                    WHERE t.fecha = fecha_param 
                    AND t.hora = h.hora_inicio 
                    AND t.estado IN ('pendiente', 'confirmado')
                ) THEN 'Ocupado'
                ELSE 'Disponible'
            END as estado
        FROM horarios_disponibles h
        WHERE h.dia_semana = dia_semana
        AND h.activo = TRUE
        ORDER BY h.hora_inicio;
    END IF;
END //
DELIMITER ;

-- Función para calcular precio con descuentos
DELIMITER //
CREATE FUNCTION CalcularPrecio(servicio_param VARCHAR(50), manos_pies_param BOOLEAN)
RETURNS DECIMAL(10,2)
READS SQL DATA
DETERMINISTIC
BEGIN
    DECLARE precio_base DECIMAL(10,2);
    DECLARE descuento DECIMAL(5,2);
    
    -- Obtener precio base
    SELECT precio INTO precio_base 
    FROM servicios 
    WHERE nombre = servicio_param AND activo = TRUE;
    
    -- Obtener porcentaje de descuento
    SELECT CAST(valor AS DECIMAL(5,2)) INTO descuento
    FROM configuracion 
    WHERE clave = 'descuento_manos_pies';
    
    -- Aplicar descuento si aplica
    IF manos_pies_param = TRUE AND servicio_param IN ('manicura', 'pedicura') THEN
        RETURN precio_base * (1 - descuento/100);
    ELSE
        RETURN precio_base;
    END IF;
END //
DELIMITER ;

-- Crear índices adicionales para optimización
CREATE INDEX idx_turnos_fecha_hora ON turnos(fecha, hora);
CREATE INDEX idx_turnos_estado_fecha ON turnos(estado, fecha);

-- Insertar algunos datos de ejemplo (opcional)
INSERT INTO turnos (nombre, telefono, email, servicio, fecha, hora, precio, estado) VALUES
('María González', '3001234567', 'maria@email.com', 'manicura', DATE_ADD(CURDATE(), INTERVAL 1 DAY), '10:00:00', 25000, 'pendiente'),
('Ana Rodríguez', '3007654321', 'ana@email.com', 'pedicura', DATE_ADD(CURDATE(), INTERVAL 2 DAY), '14:00:00', 30000, 'confirmado'),
('Laura Martínez', '3009876543', 'laura@email.com', 'nailart', DATE_ADD(CURDATE(), INTERVAL 3 DAY), '16:00:00', 35000, 'pendiente');

-- Mostrar mensaje de éxito
SELECT 'Base de datos Nail Studio inicializada correctamente' as mensaje;
