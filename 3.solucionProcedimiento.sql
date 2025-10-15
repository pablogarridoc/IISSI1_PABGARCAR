DELIMITER //

CREATE PROCEDURE bonificar_pedido_retrasado(IN p_pedidoId INT)
-- incluya su solución a continuación

BEGIN
	DECLARE v_antiguoEmpleadoId INT;
  DECLARE v_nuevoEmpleadoId INT;

  -- Manejo de errores
  DECLARE EXIT HANDLER FOR SQLEXCEPTION
  BEGIN
      ROLLBACK;
      SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error al crear bonificación.';
  END;

  -- Iniciar transacción
  START TRANSACTION;

	SELECT e.id
	INTO v_antiguoEmpleadoId
	FROM pedidos p
	JOIN empleados e ON e.id=p.empleadoId
	WHERE p.id=p_pedidoId;
	
	if v_antiguoEmpleadoId IS NULL then
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El pedido no tiene gestor.';
  	END IF;

  	SELECT id INTO v_nuevoEmpleadoId
   FROM empleados
   WHERE id != empleado
	LIMIT 1;

	UPDATE pedidos p
	SET p.empleadoId = v_nuevoEmpleadoId
	WHERE p.id=p_pedidoId;
	
	UPDATE lineaspedido lp
	SET lp.precio = lp.precio * 0.8
	WHERE p.id=p_pedidoId;
  
  -- Confirmar transacción
  COMMIT;
END//

-- fin de su solución
DELIMITER ;