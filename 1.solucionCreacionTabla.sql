DROP TABLE IF EXISTS Pagos;

CREATE TABLE Pagos (
    id INT PRIMARY KEY AUTO_INCREMENT,
    pedidoId INT NOT NULL,
    fechaPago DATE NOT NULL,
    cantidadPago DECIMAL(10, 2) NOT NULL CHECK (cantidadPago>0),
    revisado BOOL NOT NULL DEFAULT FALSE,
    FOREIGN KEY (pedidoId) REFERENCES Pedidos(id)
);
