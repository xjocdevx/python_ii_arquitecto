# MÓDULO 1 — Programación Orientada a Objetos (POO)
Ejercicio 1 — Clase Persona
```python
class Persona:
    def __init__(self, nombre, edad):
        self.nombre = nombre
        self.edad = edad

persona = Persona("Carlos", 25)
print(persona.nombre)
print(persona.edad)
```
Ejercicio 2 — Clase Animal
```python
class Animal:
    def hacer_sonido(self):
        print("Sonido del animal")

animal = Animal()
animal.hacer_sonido()
```
Ejercicio 3 — Clase Auto
```python
class Auto:
    def __init__(self, marca, modelo):
        self.marca = marca
        self.modelo = modelo

    def mostrar(self):
        print(self.marca, self.modelo)

auto = Auto("Toyota", "Corolla")
auto.mostrar()
```
Ejercicio 4 — Clase Libro
```python
class Libro:
    def __init__(self, titulo):
        self.titulo = titulo

libro = Libro("Python Básico")
print(libro.titulo)
```
Ejercicio 5 — Clase Rectangulo
```python
class Rectangulo:
    def __init__(self, base, altura):
        self.base = base
        self.altura = altura

    def area(self):
        return self.base * self.altura

r = Rectangulo(5, 3)
print(r.area())
```
Ejercicio 6 — Clase Cuenta
```python
class Cuenta:
    def __init__(self, saldo):
        self.saldo = saldo

    def depositar(self, monto):
        self.saldo += monto

cuenta = Cuenta(100)
cuenta.depositar(50)
print(cuenta.saldo)
```
Ejercicio 7 — Clase Producto
```python
class Producto:
    def __init__(self, nombre, precio):
        self.nombre = nombre
        self.precio = precio

producto = Producto("Mouse", 80)
print(producto.nombre)
print(producto.precio)
```
Ejercicio 8 — Clase Estudiante
```python
class Estudiante:
    def __init__(self, nombre, nota):
        self.nombre = nombre
        self.nota = nota

    def aprobar(self):
        return self.nota >= 51

est = Estudiante("Ana", 70)
print(est.aprobar())
```
Ejercicio 9 — Herencia Vehículo
```python
class Vehiculo:
    def mover(self):
        print("El vehículo se mueve")

class Moto(Vehiculo):
    pass

m = Moto()
m.mover()
```
Ejercicio 10 — Clase Empleado
```python
class Empleado:
    def __init__(self, nombre, salario):
        self.nombre = nombre
        self.salario = salario

    def bono(self):
        return self.salario * 0.10

emp = Empleado("Luis", 3000)
print(emp.bono())
```
Ejercicio 11 — Clase Calculadora
```python
class Calculadora:
    def sumar(self, a, b):
        return a + b

calc = Calculadora()
print(calc.sumar(5, 3))
```
Ejercicio 12 — Clase Celular
```python
class Celular:
    def llamar(self):
        print("Llamando...")

c = Celular()
c.llamar()
```
Ejercicio 13 — Clase Película
```python
class Pelicula:
    def __init__(self, nombre, duracion):
        self.nombre = nombre
        self.duracion = duracion

p = Pelicula("Matrix", 120)
print(p.nombre)
```
Ejercicio 14 — Clase Profesor
```python
class Profesor:
    def __init__(self, nombre, materia):
        self.nombre = nombre
        self.materia = materia

prof = Profesor("Mario", "Matemática")
print(prof.materia)
```
Ejercicio 15 — Clase Tienda
```python
class Tienda:
    def __init__(self):
        self.productos = []

    def agregar(self, producto):
        self.productos.append(producto)

store = Tienda()
store.agregar("Teclado")
print(store.productos)
```
Ejercicio 16 — Clase Factura
```python
class Factura:
    def __init__(self, monto):
        self.monto = monto

    def iva(self):
        return self.monto * 0.13

f = Factura(100)
print(f.iva())
```
Ejercicio 17 — Clase Banco
```python
class Banco:
    def __init__(self):
        self.clientes = []

    def agregar_cliente(self, nombre):
        self.clientes.append(nombre)

banco = Banco()
banco.agregar_cliente("Carlos")
print(banco.clientes)
```
Ejercicio 18 — Encapsulamiento
```python
class Usuario:
    def __init__(self):
        self.__password = "1234"

u = Usuario()
print("Password protegida")
```
Ejercicio 19 — Clase Computadora
```python
class Computadora:
    def __init__(self, ram):
        self.ram = ram

pc = Computadora("8GB")
print(pc.ram)
```
Ejercicio 20 — Mini Inventario
```python
class Inventario:
    def __init__(self):
        self.items = []

    def agregar(self, item):
        self.items.append(item)

inv = Inventario()
inv.agregar("Monitor")
print(inv.items)
```
# MÓDULO 2 — SQL y Pydantic

Ejercicio 1 — Crear Base de Datos
```python
import sqlite3

conexion = sqlite3.connect("empresa.db")
print("Base creada")
conexion.close()
```
Ejercicio 2 — Crear Tabla
```python
import sqlite3

conexion = sqlite3.connect("empresa.db")
cursor = conexion.cursor()

cursor.execute("""
CREATE TABLE IF NOT EXISTS usuarios(
    id INTEGER PRIMARY KEY,
    nombre TEXT
)
""")

conexion.commit()
conexion.close()
```
Ejercicio 3 — Insertar Datos
```python
import sqlite3

conexion = sqlite3.connect("empresa.db")
cursor = conexion.cursor()

cursor.execute("INSERT INTO usuarios(nombre) VALUES(?)", ("Carlos",))

conexion.commit()
conexion.close()
```
Ejercicio 4 — Listar Usuarios
```python
import sqlite3

conexion = sqlite3.connect("empresa.db")
cursor = conexion.cursor()

cursor.execute("SELECT * FROM usuarios")
usuarios = cursor.fetchall()

for u in usuarios:
    print(u)

conexion.close()
```
Ejercicio 5 — Buscar Usuario
```python
import sqlite3

conexion = sqlite3.connect("empresa.db")
cursor = conexion.cursor()

cursor.execute("SELECT * FROM usuarios WHERE id=1")
print(cursor.fetchone())

conexion.close()
```
Ejercicio 6 — Actualizar Usuario
```python
import sqlite3

conexion = sqlite3.connect("empresa.db")
cursor = conexion.cursor()

cursor.execute("UPDATE usuarios SET nombre='Ana' WHERE id=1")

conexion.commit()
conexion.close()
```
Ejercicio 7 — Eliminar Usuario
```python
import sqlite3

conexion = sqlite3.connect("empresa.db")
cursor = conexion.cursor()

cursor.execute("DELETE FROM usuarios WHERE id=1")

conexion.commit()
conexion.close()
```
Ejercicio 8 — Modelo Pydantic
```python
from pydantic import BaseModel

class Usuario(BaseModel):
    nombre: str
    edad: int

u = Usuario(nombre="Luis", edad=20)

print(u)

Ejercicio 9 — Validar Email

from pydantic import BaseModel, EmailStr

class Cliente(BaseModel):
    email: EmailStr

c = Cliente(email="correo@gmail.com")
print(c)
```
Ejercicio 10 — Validar Edad
```python
from pydantic import BaseModel

class Persona(BaseModel):
    edad: int

p = Persona(edad=25)
print(p)
```
Ejercicio 11 — Guardar Producto
```python
import sqlite3

conexion = sqlite3.connect("tienda.db")
cursor = conexion.cursor()

cursor.execute("CREATE TABLE IF NOT EXISTS productos(nombre TEXT)")
cursor.execute("INSERT INTO productos VALUES('Mouse')")

conexion.commit()
conexion.close()
```
Ejercicio 12 — Leer Productos
```python
import sqlite3

conexion = sqlite3.connect("tienda.db")
cursor = conexion.cursor()

cursor.execute("SELECT * FROM productos")
print(cursor.fetchall())

conexion.close()
```
Ejercicio 13 — Crear Tabla Ventas
```python
import sqlite3

conexion = sqlite3.connect("ventas.db")
cursor = conexion.cursor()

cursor.execute("CREATE TABLE IF NOT EXISTS ventas(total REAL)")

conexion.commit()
conexion.close()
```
Ejercicio 14 — Insertar Venta
```python
import sqlite3

conexion = sqlite3.connect("ventas.db")
cursor = conexion.cursor()

cursor.execute("INSERT INTO ventas VALUES(150)")

conexion.commit()
conexion.close()
```
Ejercicio 15 — Exportar JSON
```python
import json

persona = {
    "nombre": "Carlos",
    "edad": 25
}

with open("persona.json", "w") as archivo:
    json.dump(persona, archivo)
```
Ejercicio 16 — Leer JSON
```python
import json

with open("persona.json", "r") as archivo:
    datos = json.load(archivo)

print(datos)
```
Ejercicio 17 — CRUD Básico
```python
print("1. Crear")
print("2. Leer")
print("3. Salir")
```
Ejercicio 18 — Tabla Clientes
```python
import sqlite3

conexion = sqlite3.connect("clientes.db")
cursor = conexion.cursor()

cursor.execute("CREATE TABLE IF NOT EXISTS clientes(nombre TEXT)")

conexion.commit()
conexion.close()
```
Ejercicio 19 — Insertar Cliente
```python
import sqlite3

conexion = sqlite3.connect("clientes.db")
cursor = conexion.cursor()

cursor.execute("INSERT INTO clientes VALUES('Maria')")

conexion.commit()
conexion.close()
```
Ejercicio 20 — Mostrar Clientes
```python
import sqlite3

conexion = sqlite3.connect("clientes.db")
cursor = conexion.cursor()

cursor.execute("SELECT * FROM clientes")
print(cursor.fetchall())

conexion.close()
```
### 2. MySQL
Qué es: Un sistema gestor de bases de datos relacional más robusto y escalable que SQLite.

Características:

Requiere un servidor (local o remoto).

Soporta múltiples usuarios y conexiones simultáneas.

Ideal para aplicaciones empresariales y web.

Uso en Python:

Se maneja con librerías como mysql-connector-python o PyMySQL.

Ejemplo:

```python
import mysql.connector
conexion = mysql.connector.connect(
    host="localhost",
    user="root",
    password="1234",
    database="empresa"
)
cursor = conexion.cursor()
cursor.execute("SELECT * FROM empleados")
for fila in cursor:
    print(fila)
conexion.close()
```
### 📌 3. CRUD desde Python
CRUD significa Create, Read, Update, Delete, las operaciones básicas sobre datos.

Create (Insertar):

```python
cursor.execute("INSERT INTO empleados (nombre) VALUES ('Carlos')")
conexion.commit()
```
Read (Leer):

```python
cursor.execute("SELECT * FROM empleados")
print(cursor.fetchall())
```
Update (Actualizar):

```python
cursor.execute("UPDATE empleados SET nombre='Ana' WHERE id=1")
conexion.commit()
```
Delete (Eliminar):

```python
cursor.execute("DELETE FROM empleados WHERE id=1")
conexion.commit()
```

### 📌 4. Validación de datos con Pydantic
Qué es: Una librería de Python que permite validar y estructurar datos de manera sencilla usando modelos.

Características:

Garantiza que los datos tengan el tipo correcto.

Útil en aplicaciones que reciben datos externos (APIs, formularios).

Ejemplo:

```python
from pydantic import BaseModel

class Empleado(BaseModel):
    nombre: str
    edad: int

e = Empleado(nombre="Carlos", edad=25)
print(e.dict())
```
Validación automática:

```python
Empleado(nombre="Ana", edad="25")  # Error, porque edad no es int
```















