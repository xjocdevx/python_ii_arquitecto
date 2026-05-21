# MÓDULO 3 — APIs y JSON
Ejercicio 1 — Consumir API
```python
import requests

respuesta = requests.get("https://api.github.com")
print(respuesta.status_code)
```
Ejercicio 2 — Leer JSON
```python
import requests

respuesta = requests.get("https://api.github.com")
datos = respuesta.json()

print(datos)
```
Ejercicio 3 — Tipo de Cambio
```python
import requests

url = "https://api.exchangerate-api.com/v4/latest/USD"
datos = requests.get(url).json()

print(datos["rates"]["BOB"])
```
Ejercicio 4 — Mostrar Fecha
```python
import requests

url = "https://api.exchangerate-api.com/v4/latest/USD"
datos = requests.get(url).json()

print(datos["date"])
```
Ejercicio 5 — Consultar País
```python
import requests

url = "https://restcountries.com/v3.1/name/bolivia"
datos = requests.get(url).json()

print(datos[0]["name"]["common"])
```
Ejercicio 6 — Guardar JSON
```python
import requests
import json

respuesta = requests.get("https://api.github.com")

with open("github.json", "w") as archivo:
    json.dump(respuesta.json(), archivo)

```
Ejercicio 7 — Leer Archivo JSON
```python
import json

with open("github.json", "r") as archivo:
    datos = json.load(archivo)

print(datos)
```
Ejercicio 8 — Convertir USD a BOB
```python
usd = 10
bob = usd * 6.96

print(bob)
```
Ejercicio 9 — Manejo de Error
```python
try:
    x = 10 / 0
except:
    print("Error")
```
Ejercicio 10 — Solicitud Incorrecta
```python
import requests

try:
    requests.get("https://api.inexistente.com")
except:
    print("No se pudo conectar")
```
Ejercicio 11 — Mostrar Temperatura
```python
print("Temperatura: 20 grados")
```
Ejercicio 12 — JSON a Diccionario
```python
import json

texto = '{"nombre":"Ana"}'

datos = json.loads(texto)
print(datos)
```
Ejercicio 13 — Diccionario a JSON
```python
import json

persona = {"nombre": "Luis"}

print(json.dumps(persona))
```
Ejercicio 14 — Reintento API
```python
for i in range(3):
    print("Intento", i+1)

    









