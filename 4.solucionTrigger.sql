DELIMITER //

CREATE OR REPLACE TRIGGER t_limitar_importe_pedidos_de_menores BEFORE INSERT ON LineasPedido
FOR EACH ROW
BEGIN
    DECLARE clienteId INT DEFAULT NULL;
    DECLARE añosCliente INT ;
    DECLARE limitePrecio INT DEFAULT 500;
    DECLARE precioTotal INT ;
    DECLARE mensajeError TEXT;

    -- Obtener el cliente asociado al pedido
    SELECT p.clienteId INTO clienteId
    FROM Pedidos p
    WHERE p.id = NEW.pedidoId;

    -- Validar si el cliente asociado al pedido existe
    IF clienteId IS NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'El pedido no está asociado a un cliente válido.';
    END IF;
    
    -- Obtener la edad del cliente asociado al pedido
    
    SELECT TIMESTAMPDIFF(YEAR,clientes.fechaNacimiento,CURDATE()) INTO añosCliente
    FROM clientes
    WHERE clientes.id=clienteId;
    
    SELECT COALESCE(SUM(lp.unidades * lp.precio), 0) INTO precioTotal
    FROM  lineaspedido lp
    WHERE lp.pedidoId = NEW.pedidoId;
    
    SET precioTotal=precioTotal+(NEW.unidades*NEW.precio);

    -- Verificar si la cantidad total supera el límite
    IF añosCliente < 18 THEN
    	IF  precioTotal> limitePrecio THEN
    
        SET mensajeError = CONCAT('El pedido excede el límite de ', CAST(limitePrecio AS CHAR), ' precio permitido para clientes menores de edad.');
        SIGNAL SQLSTATE '45000'
     
	     SET MESSAGE_TEXT = mensajeError;
	     END IF;
    END IF;
END //

DELIMITER ;

