DELIMITER //

CREATE OR REPLACE  TRIGGER  t_asegurar_mismo_tipo_producto_en_pedidos
BEFORE INSERT ON lineaspedido
FOR EACH ROW
BEGIN
    DECLARE v_tipo_nuevo INT;
    DECLARE v_existe_diferente BOOLEAN DEFAULT FALSE;

    -- Obtener el tipo del nuevo producto
    SELECT tipoProductoId INTO v_tipo_nuevo
    FROM productos
    WHERE id = NEW.productoId;

    -- Verificar si hay algún producto de tipo distinto en el mismo pedido
    SELECT EXISTS (
        SELECT 1
        FROM lineaspedido lp
        JOIN productos p ON lp.productoId = p.id
        WHERE lp.pedidoId = NEW.pedidoId
          AND p.tipoProductoId != v_tipo_nuevo
    ) INTO v_existe_diferente;

    IF v_existe_diferente THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Un mismo pedido no puede contener productos físicos y digitales.';
    END IF;
END//

DELIMITER ;

