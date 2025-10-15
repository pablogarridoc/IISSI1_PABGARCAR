SELECT productos.nombre,tiposproducto.nombre,productos.precio
FROM productos JOIN tiposproducto ON tiposproducto.id=productos.tipoProductoId
WHERE productos.tipoProductoId=2;

SELECT 
  usuarios.nombre,
  COUNT(DISTINCT CASE 
                    WHEN YEAR(pedidos.fechaRealizacion) = 2024 AND 
                         (SELECT SUM(lp.precio * lp.unidades) 
                          FROM lineaspedido lp 
                          WHERE lp.pedidoId = pedidos.id) > 500
                    THEN pedidos.id 
                 END) AS num_pedidos,
  SUM(CASE 
        WHEN YEAR(pedidos.fechaRealizacion) = 2024
        THEN lineaspedido.precio * lineaspedido.unidades 
        ELSE 0 
      END) AS importe_total
FROM empleados
LEFT JOIN pedidos ON pedidos.empleadoId = empleados.id
LEFT JOIN lineaspedido ON pedidos.id = lineaspedido.pedidoId
JOIN usuarios ON usuarios.id = empleados.usuarioId
GROUP BY empleados.id
ORDER BY importe_total DESC;





