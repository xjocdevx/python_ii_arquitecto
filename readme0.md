### 📘 POO en Python – Guía práctica
# 1. Clases y objetos

Una clase es un molde. Un objeto es una instancia de ese molde.
python

class Perro:
    pass  # clase vacía

mi_perro = Perro()   # crear un objeto
print(type(mi_perro))  # <class '__main__.Perro'>

# 2. Atributos
Atributos de instancia

Pertenecen a cada objeto por separado. Se definen en __init__.
python

class Gato:
    def __init__(self, nombre, edad):
        self.nombre = nombre   # atributo de instancia
        self.edad = edad

michi = Gato("Bigotes", 3)
print(michi.nombre)  # Bigotes

Atributos de clase

Se comparten entre todas las instancias.
python

class Vehiculo:
    ruedas = 4   # atributo de clase

coche = Vehiculo()
moto = Vehiculo()
print(coche.ruedas)  # 4
print(moto.ruedas)   # 4
Vehiculo.ruedas = 3  # cambia para todos
print(coche.ruedas)  # 3

# 3. Métodos
Método de instancia

Recibe self y puede acceder/modificar atributos del objeto.
python

class Calculadora:
    def sumar(self, a, b):
        return a + b

calc = Calculadora()
print(calc.sumar(5, 3))  # 8

Método de clase

Recibe cls (la clase). Se define con @classmethod.
python

class Persona:
    especie = "Humano"

    @classmethod
    def info_especie(cls):
        return f"Especie: {cls.especie}"

print(Persona.info_especie())  # Especie: Humano

Método estático

No recibe self ni cls. Es como una función normal dentro de la clase. Se define con @staticmethod.
python

class Matematicas:
    @staticmethod
    def es_par(numero):
        return numero % 2 == 0

print(Matematicas.es_par(7))  # False

# 4. Encapsulamiento

En Python no hay modificadores private / protected estrictos, pero usamos convenciones:

    _atributo → "protected" (no debería usarse fuera de la clase)

    __atributo → "private" (name mangling: _Clase__atributo)

Uso de properties (getters/setters al estilo Python)
python

class CuentaBancaria:
    def __init__(self, saldo):
        self.__saldo = saldo   # atributo privado

    @property
    def saldo(self):
        """Getter: se accede como atributo"""
        return self.__saldo

    @saldo.setter
    def saldo(self, valor):
        """Setter: validación antes de modificar"""
        if valor < 0:
            raise ValueError("El saldo no puede ser negativo")
        self.__saldo = valor

cuenta = CuentaBancaria(1000)
print(cuenta.saldo)    # 1000 (parece atributo, pero ejecuta getter)
cuenta.saldo = 500     # usa setter
print(cuenta.saldo)    # 500
# cuenta.saldo = -50   # Lanza ValueError

# 5. Herencia

Una clase hereda atributos y métodos de otra.
python

class Animal:
    def __init__(self, nombre):
        self.nombre = nombre

    def hacer_sonido(self):
        return "..."

class Perro(Animal):      # Hereda de Animal
    def hacer_sonido(self):
        return "¡Guau!"   # Sobrescribe método

class Gato(Animal):
    def hacer_sonido(self):
        return "¡Miau!"

firulais = Perro("Firulais")
print(firulais.nombre)      # Firulais (heredado)
print(firulais.hacer_sonido())  # ¡Guau!

super() – llamar al método de la clase padre
python

class Mascota(Animal):
    def __init__(self, nombre, dueno):
        super().__init__(nombre)   # inicializa atributo nombre
        self.dueno = dueno

m = Mascota("Luna", "Carlos")
print(m.nombre, m.dueno)   # Luna Carlos

Herencia múltiple y MRO (Method Resolution Order)
python

class A:
    def saludar(self):
        return "Hola desde A"

class B:
    def saludar(self):
        return "Hola desde B"

class C(A, B):   # hereda primero de A, luego de B
    pass

obj = C()
print(obj.saludar())          # Hola desde A
print(C.__mro__)              # Muestra orden: (C, A, B, object)

# 6. Polimorfismo

Mismo nombre de método, comportamiento diferente según el objeto.
python

class Pato:
    def hablar(self):
        return "Cuac"

class Vaca:
    def hablar(self):
        return "Muu"

def hacer_hablar(animal):
    print(animal.hablar())

p = Pato()
v = Vaca()
hacer_hablar(p)   # Cuac
hacer_hablar(v)   # Muu

# 7. Clases abstractas (ABC)

Definen métodos que obligatoriamente deben implementar las clases hijas.
python

from abc import ABC, abstractmethod

class Figura(ABC):
    @abstractmethod
    def area(self):
        pass   # las hijas deben implementar esto

class Circulo(Figura):
    def __init__(self, radio):
        self.radio = radio

    def area(self):
        return 3.1416 * self.radio ** 2

#fig = Figura()        # Error: no se puede instanciar clase abstracta
circulo = Circulo(5)
print(circulo.area())    # 78.54

# 8. Ejemplo completo integrador
python

class Empleado:
    def __init__(self, nombre, salario_base):
        self.nombre = nombre
        self._salario_base = salario_base   # protegido

    @property
    def salario_base(self):
        return self._salario_base

    def calcular_salario(self):
        return self._salario_base

class Vendedor(Empleado):
    def __init__(self, nombre, salario_base, comision):
        super().__init__(nombre, salario_base)
        self.comision = comision

    def calcular_salario(self):
        return self.salario_base + self.comision

class Gerente(Empleado):
    def __init__(self, nombre, salario_base, bono):
        super().__init__(nombre, salario_base)
        self.bono = bono

    def calcular_salario(self):
        return self.salario_base + self.bono

#Uso polimórfico
empleados = [
    Empleado("Ana", 1000),
    Vendedor("Luis", 800, 200),
    Gerente("Eva", 2000, 500)
]

for emp in empleados:
    print(f"{emp.nombre}: ${emp.calcular_salario()}")
