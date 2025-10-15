DROP TABLE IF EXISTS Valoraciones;

CREATE TABLE Valoraciones (
    id INT PRIMARY KEY AUTO_INCREMENT,
    clienteId INT NOT NULL,
    productoId INT NOT NULL,
    puntuacion INT NOT NULL CHECK (puntuacion>=1 AND puntuacion<=5),
    fechaValoracion DATE NOT NULL,
    UNIQUE(clienteId,productoId),
    FOREIGN KEY (clienteId) REFERENCES clientes(id),
    FOREIGN KEY (productoId) REFERENCES Productos(id)
	 	ON DELETE CASCADE 
		ON UPDATE CASCADE
);