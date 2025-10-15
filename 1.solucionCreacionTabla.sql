DROP TABLE IF EXISTS Garantias;

CREATE TABLE Garantias (
    id INT PRIMARY KEY AUTO_INCREMENT,
    productoId INT NOT NULL ,
    fechaInicio DATE NOT NULL,
    fechFin DATE NOT NULL CHECK 
	 (fechFin>fechaInicio),
    garantiaExtendida BOOLEAN NOT NULL,
    FOREIGN KEY (productoId) REFERENCES Productos(id),
    UNIQUE(id,productoId)
);