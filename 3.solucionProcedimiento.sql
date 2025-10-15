 DELIMITER //

CREATE PROCEDURE actualizar_precio_producto(
  IN p_productoId INT,
  IN p_precioNuevo DECIMAL(10, 2)
)
BEGIN
  DECLARE v_precioProducto DECIMAL(10, 2);
  

  -- Manejo de errores
  DECLARE EXIT HANDLER FOR SQLEXCEPTION
  BEGIN
      ROLLBACK;
      SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error al actualizar el precio del producto';
  END;

  -- Iniciar transacción
  START TRANSACTION;

  -- Averiguar el precio del producto dado
  SELECT productos.precio
  INTO v_precioProducto
  FROM productos 
  WHERE productos.id=p_productoId;

  IF p_precioNuevo<v_precioProducto*0.5 THEN
      SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No se permite rebajar el precio m·s del 50%.';
  END IF;

  -- Actualiza el precio del producto 
  UPDATE productos SET productos.precio=p_precioNuevo WHERE productos.id=p_productoId;
  
  -- Actualiza las lineas de pedido que contengan ese producto
  UPDATE lineaspedido 
  JOIN pedidos ON pedidos.id=lineaspedido.id
  SET lineaspedido.precio=p_precioNuevo 
  WHERE lineaspedido.productoId=p_productoId
  AND pedidos.fechaEnvio IS NULL;

  

  -- Confirmar transacción
  COMMIT;
END//

DELIMITER ;
