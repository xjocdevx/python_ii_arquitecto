Instalar dependencias

´´´python
pip install pytest
´´´

Archivos de prueba separados (para pytest)
test_parte4.py
´´´python
import pytest
from parte4_codigo import es_par, calcular_descuento, promedio

# Ejercicio 11
def test_es_par():
    assert es_par(2) == True
    assert es_par(3) == False
    assert es_par(0) == True

# Ejercicio 12
@pytest.mark.parametrize("precio,porcentaje,esperado", [
    (100, 10, 90),
    (200, 0, 200),
    (50, 20, 40)
])
def test_calcular_descuento(precio, porcentaje, esperado):
    assert calcular_descuento(precio, porcentaje) == esperado

# Ejercicio 16
@pytest.fixture
def lista_numeros():
    return [1, 2, 3, 4, 5]

def test_promedio(lista_numeros):
    assert promedio(lista_numeros) == 3.0

´´´
    test_desafio.py
python
import pytest
from desafio_final import Venta, GestorVentas

def test_venta_validacion():
    venta = Venta(producto="Test", cantidad=2, precio_unitario=10.5)
    assert venta.total == 21.0
    
    with pytest.raises(ValueError):
        Venta(producto="Test", cantidad=0, precio_unitario=10.5)
    
    with pytest.raises(ValueError):
        Venta(producto="", cantidad=1, precio_unitario=10.5)

def test_gestor_registro():
    gestor = GestorVentas()
    venta, id_venta = gestor.registrar_venta("Prueba", 3, 20.0)
    assert venta.producto == "Prueba"
    assert venta.total == 60.0
    assert id_venta is not None
