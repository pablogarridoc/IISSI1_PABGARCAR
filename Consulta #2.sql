DROP TABLE IF EXISTS Promociones;

CREATE TABLE Promociones (
    id INT PRIMARY KEY AUTO_INCREMENT,
    productoId INT NOT NULL,
    descuento DECIMAL(10,2) NOT NULL CHECK (descuento>0.00 AND descuento <=1.00),
    fechaInicio DATE NOT NULL,
    fechaFin DATE NOT NULL CHECK (fechaInicio < fechaFin),
    FOREIGN KEY (productoId) REFERENCES Productos(id)
        ON DELETE CASCADE 
        ON UPDATE CASCADE
);

INSERT INTO Promociones (productoId, descuento, fechaInicio,fechaFin) VALUES
(1, 0.1,'2024-01-01', '2024-01-15'),
(1, 0.15,'2025-01-01', '2025-01-15'),
(1, 0.2,'2025-06-01', '2025-06-30'),
(2, 0.3,'2024-07-01', '2024-07-31'),
(2, 0.2,'2025-07-01', '2025-07-31'),
(3, 0.1,'2025-07-01', '2025-07-31'),
(4, 0.4,'2025-08-01', '2025-08-31'),
(7, 0.05,'2025-06-01', '2025-06-30'),
(9, 0.1,'2025-07-01', '2025-07-31');



SELECT prd.id, prd.nombre
FROM productos prd
WHERE prd.id NOT IN (select productoId FROM promociones);

SELECT prd.id,prd.nombre,prd.precio,(prd.precio * (1.00 - promo.descuento)) AS PCD
FROM productos prd
JOIN promociones promo ON promo.productoId=prd.id;

SELECT prd.id,prd.nombre, COUNT(promo.productoId) AS numPromo
FROM productos prd
LEFT JOIN promociones promo ON promo.productoId=prd.id
GROUP BY prd.id
ORDER BY numPromo DESC;


DROP TRIGGER IF EXISTS trg_actualizar_precio_pedido_promocion;

DELIMITER //

CREATE TRIGGER trg_actualizar_precio_pedido_promocion
BEFORE INSERT ON LineasPedido
FOR EACH ROW
BEGIN
    DECLARE v_fechaPedido DATE;
    DECLARE v_descuento DECIMAL(3,2);

    -- Obtener la fecha del pedido al que pertenece la línea
    SELECT fechaRealizacion INTO v_fechaPedido
    FROM Pedidos
    WHERE id = NEW.pedidoId;

    -- Buscar si hay una promoción activa para el producto en esa fecha
    SELECT descuento
    INTO v_descuento
    FROM Promociones
    WHERE productoId = NEW.productoId
      AND v_fechaPedido BETWEEN fechaInicio AND fechaFin
    ORDER BY fechaInicio DESC
    LIMIT 1;

    -- Si existe promoción, aplicar descuento al precio
    IF v_descuento IS NOT NULL THEN
        SET NEW.precio = NEW.precio * (1 - v_descuento);
    END IF;
END;
//

DELIMITER ;



DELIMITER //

DROP PROCEDURE IF EXISTS p_anularPedido //
CREATE PROCEDURE p_anularPedido(IN p_pedidoId INT)
BEGIN
    DECLARE v_existe INT DEFAULT 0;

    -- Cualquier error ⇒ rollback y re-lanzar
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    START TRANSACTION;

    -- 1) Comprobar que el pedido existe (y bloquearlo para coherencia)
    SELECT COUNT(*) INTO v_existe
    FROM Pedidos
    WHERE id = p_pedidoId
    FOR UPDATE;

    IF v_existe = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El pedido indicado no existe';
    END IF;

    -- 2) Devolver stock: sumar las unidades de cada producto del pedido
    UPDATE Productos p
    JOIN (
        SELECT lp.productoId, SUM(lp.unidades) AS unidades
        FROM LineasPedido lp
        WHERE lp.pedidoId = p_pedidoId
        GROUP BY lp.productoId
    ) t ON t.productoId = p.id
    SET p.stock = p.stock + t.unidades;

    -- 3) Borrar líneas del pedido (por la FK)
    DELETE FROM LineasPedido
    WHERE pedidoId = p_pedidoId;

    -- 4) Borrar el pedido
    DELETE FROM Pedidos
    WHERE id = p_pedidoId;

    COMMIT;
END //
//
DELIMITER ;



























