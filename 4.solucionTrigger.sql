DELIMITER //
-- incluya su solución a continuación
CREATE OR REPLACE TRIGGER p_limitar_unidades_mensuales_de_productos_fisicos 
BEFORE INSERT ON LineasPedido
FOR EACH ROW
BEGIN
    DECLARE tipoProducto INT;
    DECLARE unidadesTotales INT DEFAULT 0;
    DECLARE fecha DATE;
    
    -- Obtener el cliente asociado al pedido
    SELECT productos.tipoProductoId INTO tipoProducto
    FROM productos 
    WHERE id = NEW.productoId;

    -- Validar si el cliente asociado al pedido existe
   IF tipoProducto =1 THEN
    
    	SELECT p.fechaRealizacion INTO fecha
    	FROM pedidos p
    	WHERE p.id=NEW.pedidoId;
    	
    	SELECT COALESCE(SUM(lp.unidades),0) INTO unidadesTotales
    	FROM lineaspedido lp
		JOIN pedidos ON pedidos.id = lineaspedido.pedidoId
      WHERE lineaspedido.productoId = NEW.productoId
   		AND MONTH(pedidos.fechaRealizacion) = MONTH(fecha)
         AND YEAR(pedidos.fechaRealizacion) = YEAR(fecha);
    	
    	if (NEW.unidades + unidadesTotales) > 1000 then 
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Se ha superado el limite de unidades mensuales.';
   	END IF;
	END IF;
END //

-- fin de su solución
DELIMITER ;