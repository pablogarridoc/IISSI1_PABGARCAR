SELECT uEmpleados.nombre AS nombreEmpleado,
pedidos.fechaRealizacion,
uClientes.nombre AS nombreCliente
FROM pedidos 
JOIN empleados ON pedidos.empleadoId=empleados.id
JOIN usuarios AS uEmpleados ON uEmpleados.id=empleados.usuarioId
JOIN clientes ON pedidos.clienteId=clientes.id
JOIN usuarios as uClientes ON uClientes.id=clientes.usuarioId
WHERE MONTH (pedidos.fechaRealizacion)=MONTH(CURDATE());

SELECT usuarios.nombre,SUM(lineaspedido.unidades),
SUM(lineaspedido.unidades*lineaspedido.precio)
FROM pedidos 
JOIN lineaspedido ON pedidos.id=lineaspedido.pedidoId
JOIN clientes ON pedidos.clienteId=clientes.id
JOIN usuarios ON usuarios.id=clientes.usuarioId
WHERE YEAR (pedidos.fechaRealizacion)=2024
GROUP BY clientes.id
HAVING COUNT(DISTINCT(pedidos.id))>5;

