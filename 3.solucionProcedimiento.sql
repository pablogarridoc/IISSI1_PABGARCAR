 DELIMITER //

CREATE PROCEDURE r(
  IN p_nombre VARCHAR(255),
  IN p_descripción TEXT,
  IN p_precio DECIMAL(10, 2),
  IN p_tipoProductoId INT,
  IN p_puedeVenderseAMenores BOOLEAN,
  IN p_regalo BOOLEAN
  
)
BEGIN
  DECLARE v_productoId INT;
  DECLARE v_pedidoId INT;
  DECLARE v_lineaspedidoId INT;
  DECLARE v_clienteId INT;#CLIENTE MAS ANTIGUO
  DECLARE v_direccionEntrega VARCHAR(255);
  DECLARE v_empleadoId INT;

  -- Manejo de errores
  DECLARE EXIT HANDLER FOR SQLEXCEPTION
  BEGIN
      ROLLBACK;
      SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error al registrar el nuevo producto';
  END;

  -- Iniciar transacción
  START TRANSACTION;


  IF p_regalo IS TRUE THEN
      if p_precio>50 then 
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No se permite crear un producto para regalo de más de 50€.'; 
		 END IF;
  END IF;
  
  
  INSERT INTO productos(nombre,descripción,precio,tipoProductoId,puedeVenderseAMenores)
  VALUES(p_nombre,p_descripción,p_precio,p_tipoProductoId,p_puedeVenderseAMenores);
   
  SET v_productoId = LAST_INSERT_ID();
  
  #Consultamos el id del cliente mas antiguo
  
  SELECT clientes.id INTO v_clienteId
  FROM pedidos JOIN clientes ON pedidos.clienteId=clientes.id
  GROUP BY clientes.id
  ORDER BY pedidos.fechaRealizacion ASC
  LIMIT 1;
  
  #Consultamos la direcion del cliente mas antiguo 
  SELECT pedidos.direccionEntrega INTO v_direccionEntrega
  FROM pedidos JOIN clientes ON clientes.id=pedidos.clienteId
  GROUP BY clientes.id
  HAVING clientes.id=v_clienteId;
  
  #cogemos un id random de trabajador
  SELECT empleados.id INTO v_empleadoId
  FROM empleados 
  GROUP BY empleados.id
  LIMIT 1;
  
  
  
	IF p_regalo IS TRUE THEN
  		INSERT INTO pedidos(fechaRealizacion ,fechaEnvio,direccionEntrega,comentarios,clienteId,empleadoId)
  		VALUES(CURDATE(),CURDATE(),v_direccionEntrega,'Que disfrute su regalo',v_clienteId,v_empleadoId);
  		
  		SET v_pedidoId = LAST_INSERT_ID();
  		
  		INSERT INTO lineaspedido(pedidoId,productoId,unidades,precio)
  		VALUES(v_pedidoId,v_productoId,1,0);
  		
  		SET v_lineaspedidoId = LAST_INSERT_ID();
  END IF;

  -- Confirmar transacción
  COMMIT;
END//

DELIMITER ;
