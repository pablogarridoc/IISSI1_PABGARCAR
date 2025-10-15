-- 2.1
SELECT prd.nombre, prd.precio, lp.unidades
FROM lineaspedido lp
JOIN productos prd ON prd.id=lp.productoId
ORDER BY lp.unidades DESC
LIMIT 5;

-- 2.3
SELECT usuarios.nombre,pedidos.fechaRealizacion,sum(lineaspedido.precio*lineaspedido.unidades) AS preciototal,lineaspedido.unidades
FROM usuarios 
JOIN empleados ON empleados.usuarioId=usuarios.id
RIGHT JOIN pedidos ON empleados.id=pedidos.empleadoId
JOIN lineaspedido ON lineaspedido.pedidoId=pedidos.id
GROUP BY pedidos.id
HAVING TIMESTAMPDIFF(DAY,pedidos.fechaRealizacion,CURDATE())>=7;