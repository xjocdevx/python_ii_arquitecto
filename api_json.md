# 📘 Parte 3 – Espionaje y Conexión: APIs y JSON
### Objetivos
Comprender el protocolo HTTP y el formato JSON.

Consumir APIs REST públicas con requests.

Implementar estrategias de reintento ante fallos de red/servidor.

Temario
### 1. HTTP y JSON básicos

Verbos (GET, POST), códigos de estado.

Estructura JSON: objetos, arrays, anidamiento.

### 2. Consumo de APIs externas con requests

requests.get(), response.json().

Manejo de headers, parámetros (params), autenticación simple.

### 3. Manejo de errores comunes

Timeouts, conexión, errores HTTP (4xx, 5xx).

Excepciones: RequestException, JSONDecodeError.

### 4. Estrategias de reintento

try/except con bucles y contadores.

Uso de time.sleep() con backoff lineal o exponencial.

Introducción a tenacity (opcional, para casos avanzados).

### 5. Ejercicio práctico

Consumir API de cotización del dólar (por ejemplo, dolarapi.com o exchangerate.host).

Mostrar valor compra/venta con reintentos automáticos.
# 📁 Estructura de archivos
text
api_mysql_exercises/
│
├── config.py                 # Configuración común (conexión DB)
├── 01_guardar_post_api.py
├── 02_leer_posts_mysql.py
├── 03_sincronizar_posts.py
├── 04_usuarios_relacion.py
├── 05_join_posts_usuarios.py
├── 06_reintentos_transaccion.py
├── 07_clima_historico.py
├── 08_dolar_historico.py
├── 09_actualizar_company.py
├── 10_exportar_json_backup.py
├── 11_api_paginada_lotes.py
├── 12_filtros_parametrizados.py
├── 13_columna_json_mysql.py
├── 14_pokemon_normalizado.py
├── 15_logs_api_mysql.py
├── 16_cache_mysql.py
├── 17_sincronizacion_bidireccional.py
├── 18_webhook_simulado.py
├── 19_dashboard_metricas.py
└── 20_proyecto_final_ventas.py
### 🔧 Archivo de configuración común
config.py
```python
"""
Archivo de configuración compartido para todos los ejercicios
Importar en cada script: from config import DB_CONFIG, crear_conexion
"""
import mysql.connector
from mysql.connector import Error

# Configuración de conexión - CAMBIAR SEGÚN TU ENTORNO
DB_CONFIG = {
    'host': 'localhost',
    'database': 'api_exercises',
    'user': 'root',
    'password': 'tu_password'
}

def crear_conexion():
    """Crea y retorna una conexión a MySQL"""
    try:
        conn = mysql.connector.connect(**DB_CONFIG)
        return conn
    except Error as e:
        print(f"Error de conexión: {e}")
        return None

def crear_base_datos():
    """Crea la base de datos si no existe"""
    conn = mysql.connector.connect(
        host='localhost',
        user='root',
        password='tu_password'
    )
    cursor = conn.cursor()
    cursor.execute("CREATE DATABASE IF NOT EXISTS api_exercises")
    conn.commit()
    cursor.close()
    conn.close()
```
### 📝 Ejercicios con nombres de archivo
🔹 Nivel 1 – Fundamentos
01_guardar_post_api.py
```python
"""
Ejercicio 1: Guardar respuesta de API en MySQL
Archivo: 01_guardar_post_api.py
API: JSONPlaceholder - posts
Objetivo: Almacenar un post completo en tabla MySQL
"""
from config import DB_CONFIG, crear_base_datos
import mysql.connector
import requests

# Crear base de datos primero
crear_base_datos()

def crear_tabla_posts():
    conn = mysql.connector.connect(**DB_CONFIG)
    cursor = conn.cursor()
    
    cursor.execute("""
        CREATE TABLE IF NOT EXISTS posts (
            id INT PRIMARY KEY,
            user_id INT,
            title VARCHAR(255),
            body TEXT,
            fecha_obtencion TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        )
    """)
    conn.commit()
    cursor.close()
    conn.close()
    print("✅ Tabla 'posts' creada/verificada")

def guardar_post(post):
    conn = mysql.connector.connect(**DB_CONFIG)
    cursor = conn.cursor()
    
    sql = "INSERT INTO posts (id, user_id, title, body) VALUES (%s, %s, %s, %s)"
    values = (post['id'], post['userId'], post['title'], post['body'])
    
    try:
        cursor.execute(sql, values)
        conn.commit()
        print(f"✅ Post {post['id']} guardado: {post['title'][:50]}")
    except mysql.connector.Error as e:
        print(f"Error: {e}")
    finally:
        cursor.close()
        conn.close()

# Ejecución principal
if __name__ == "__main__":
    crear_tabla_posts()
    
    url = "https://jsonplaceholder.typicode.com/posts/1"
    response = requests.get(url)
    post = response.json()
    
    guardar_post(post)
```
### 02_leer_posts_mysql.py
```python
"""
Ejercicio 2: Leer datos guardados desde MySQL
Archivo: 02_leer_posts_mysql.py
Objetivo: Consultar y mostrar registros almacenados
"""
from config import DB_CONFIG
import mysql.connector

def obtener_todos_posts():
    conn = mysql.connector.connect(**DB_CONFIG)
    cursor = conn.cursor(dictionary=True)
    
    cursor.execute("SELECT * FROM posts ORDER BY id DESC LIMIT 10")
    posts = cursor.fetchall()
    
    cursor.close()
    conn.close()
    return posts

def obtener_post_por_id(post_id):
    conn = mysql.connector.connect(**DB_CONFIG)
    cursor = conn.cursor(dictionary=True)
    
    cursor.execute("SELECT * FROM posts WHERE id = %s", (post_id,))
    post = cursor.fetchone()
    
    cursor.close()
    conn.close()
    return post

if __name__ == "__main__":
    print("=== Últimos 10 posts ===")
    posts = obtener_todos_posts()
    for post in posts:
        print(f"ID: {post['id']} | Título: {post['title'][:50]}")
        print(f"  Fecha: {post['fecha_obtencion']}")
        print("-" * 50)
    
    print("\n=== Buscar post específico ===")
    post = obtener_post_por_id(1)
    if post:
        print(f"Post 1: {post['title']}")
        print(f"Cuerpo: {post['body'][:100]}...")
```
03_sincronizar_posts.py
```python
"""
Ejercicio 3: Sincronizar múltiples posts desde API
Archivo: 03_sincronizar_posts.py
Objetivo: Obtener varios recursos y guardarlos en lote
"""
from config import DB_CONFIG
import requests
import mysql.connector

def sincronizar_posts(limit=10):
    conn = mysql.connector.connect(**DB_CONFIG)
    cursor = conn.cursor()
    
    url = f"https://jsonplaceholder.typicode.com/posts?_limit={limit}"
    response = requests.get(url)
    posts = response.json()
    
    sql = """INSERT IGNORE INTO posts (id, user_id, title, body) 
             VALUES (%s, %s, %s, %s)"""
    
    for post in posts:
        values = (post['id'], post['userId'], post['title'], post['body'])
        cursor.execute(sql, values)
    
    conn.commit()
    print(f"✅ Sincronizados {len(posts)} nuevos posts")
    
    cursor.close()
    conn.close()
    return len(posts)

def contar_posts():
    conn = mysql.connector.connect(**DB_CONFIG)
    cursor = conn.cursor()
    cursor.execute("SELECT COUNT(*) FROM posts")
    count = cursor.fetchone()[0]
    cursor.close()
    conn.close()
    return count

if __name__ == "__main__":
    print(f"Posts actuales: {contar_posts()}")
    sincronizar_posts(15)
    print(f"Posts después de sincronizar: {contar_posts()}")
```
### 04_usuarios_relacion.py
```python
"""
Ejercicio 4: API de usuarios + tabla relacionada
Archivo: 04_usuarios_relacion.py
Objetivo: Modelar relaciones uno-a-muchos con datos de API
"""
from config import DB_CONFIG
import requests
import mysql.connector

def crear_tablas_relacionales():
    conn = mysql.connector.connect(**DB_CONFIG)
    cursor = conn.cursor()
    
    # Tabla de usuarios
    cursor.execute("""
        CREATE TABLE IF NOT EXISTS usuarios (
            id INT PRIMARY KEY,
            name VARCHAR(100),
            username VARCHAR(50),
            email VARCHAR(100),
            phone VARCHAR(50),
            website VARCHAR(100)
        )
    """)
    
    # Verificar y agregar foreign key
    cursor.execute("""
        SELECT COUNT(*) FROM information_schema.KEY_COLUMN_USAGE 
        WHERE CONSTRAINT_NAME = 'fk_usuario' AND TABLE_NAME = 'posts'
    """)
    
    if cursor.fetchone()[0] == 0:
        try:
            cursor.execute("""
                ALTER TABLE posts 
                ADD CONSTRAINT fk_usuario 
                FOREIGN KEY (user_id) REFERENCES usuarios(id)
            """)
            print("✅ Foreign key creada")
        except Exception as e:
            print(f"Nota: {e}")
    
    conn.commit()
    cursor.close()
    conn.close()

def guardar_usuarios_api():
    url = "https://jsonplaceholder.typicode.com/users"
    response = requests.get(url)
    usuarios = response.json()
    
    conn = mysql.connector.connect(**DB_CONFIG)
    cursor = conn.cursor()
    
    sql = """
        INSERT INTO usuarios (id, name, username, email, phone, website) 
        VALUES (%s, %s, %s, %s, %s, %s)
        ON DUPLICATE KEY UPDATE
        name = VALUES(name), username = VALUES(username)
    """
    
    for u in usuarios:
        values = (u['id'], u['name'], u['username'], u['email'], u['phone'], u['website'])
        cursor.execute(sql, values)
    
    conn.commit()
    print(f"✅ Guardados {len(usuarios)} usuarios")
    
    cursor.close()
    conn.close()

if __name__ == "__main__":
    crear_tablas_relacionales()
    guardar_usuarios_api()
```
### 05_join_posts_usuarios.py
```python
"""
Ejercicio 5: JOIN entre API y BD (mostrar posts con nombre de usuario)
Archivo: 05_join_posts_usuarios.py
Objetivo: Mostrar datos combinados usando JOIN
"""
from config import DB_CONFIG
import mysql.connector

def obtener_posts_con_usuario():
    conn = mysql.connector.connect(**DB_CONFIG)
    cursor = conn.cursor(dictionary=True)
    
    query = """
        SELECT p.id, p.title, p.body, 
               u.name as autor, u.email, u.username
        FROM posts p
        JOIN usuarios u ON p.user_id = u.id
        ORDER BY p.id
        LIMIT 10
    """
    
    cursor.execute(query)
    resultados = cursor.fetchall()
    
    cursor.close()
    conn.close()
    return resultados

def obtener_estadisticas_usuario():
    conn = mysql.connector.connect(**DB_CONFIG)
    cursor = conn.cursor(dictionary=True)
    
    query = """
        SELECT u.name, u.username, COUNT(p.id) as total_posts
        FROM usuarios u
        LEFT JOIN posts p ON u.id = p.user_id
        GROUP BY u.id
        ORDER BY total_posts DESC
    """
    
    cursor.execute(query)
    stats = cursor.fetchall()
    
    cursor.close()
    conn.close()
    return stats

if __name__ == "__main__":
    print("=== Posts con datos de usuario ===\n")
    posts = obtener_posts_con_usuario()
    for post in posts:
        print(f"📝 [{post['id']}] {post['title'][:60]}")
        print(f"   Autor: {post['autor']} (@{post['username']})")
        print()
    
    print("\n=== Estadísticas por usuario ===\n")
    stats = obtener_estadisticas_usuario()
    for stat in stats:
        print(f"👤 {stat['name']} (@{stat['username']}): {stat['total_posts']} posts")
```
### 🔸 Nivel 2 – Reintentos y transacciones
06_reintentos_transaccion.py
```python
"""
Ejercicio 6: Reintentos + Transacciones MySQL
Archivo: 06_reintentos_transaccion.py
Objetivo: Asegurar consistencia de datos ante fallos de API
"""
from config import DB_CONFIG
import requests
import time
import mysql.connector

def obtener_api_con_reintentos(url, max_intentos=3):
    for intento in range(max_intentos):
        try:
            print(f"  Intento {intento+1}/{max_intentos}...")
            response = requests.get(url, timeout=5)
            response.raise_for_status()
            return response.json()
        except requests.exceptions.RequestException as e:
            print(f"  Falló: {e}")
            if intento < max_intentos - 1:
                wait = 2 ** intento
                print(f"  Esperando {wait}s...")
                time.sleep(wait)
    return None

def guardar_post_transaccional(post_data):
    conn = mysql.connector.connect(**DB_CONFIG)
    cursor = conn.cursor()
    
    try:
        conn.start_transaction()
        print("🔄 Iniciando transacción...")
        
        sql = "INSERT INTO posts (id, user_id, title, body) VALUES (%s, %s, %s, %s)"
        cursor.execute(sql, (post_data['id'], post_data['userId'], 
                            post_data['title'], post_data['body']))
        
        # Simular verificación adicional
        cursor.execute("SELECT COUNT(*) FROM usuarios WHERE id = %s", (post_data['userId'],))
        if cursor.fetchone()[0] == 0:
            raise Exception(f"Usuario {post_data['userId']} no existe en BD")
        
        conn.commit()
        print("✅ Transacción COMMIT exitosa")
        return True
        
    except Exception as e:
        conn.rollback()
        print(f"❌ Transacción ROLLBACK: {e}")
        return False
    finally:
        cursor.close()
        conn.close()

if __name__ == "__main__":
    print("=== Obteniendo post de API con reintentos ===")
    url = "https://jsonplaceholder.typicode.com/posts/3"
    data = obtener_api_con_reintentos(url)
    
    if data:
        print(f"\n✅ Post obtenido: {data['title'][:50]}")
        guardar_post_transaccional(data)
```
### 07_clima_historico.py
```python
"""
Ejercicio 7: API de clima + tabla con registros históricos
Archivo: 07_clima_historico.py
API: wttr.in (clima gratuito)
Objetivo: Almacenar mediciones periódicas
"""
from config import DB_CONFIG
import requests
import mysql.connector
from datetime import datetime

def crear_tabla_clima():
    conn = mysql.connector.connect(**DB_CONFIG)
    cursor = conn.cursor()
    
    cursor.execute("""
        CREATE TABLE IF NOT EXISTS registros_clima (
            id INT AUTO_INCREMENT PRIMARY KEY,
            ciudad VARCHAR(100),
            temperatura_celsius DECIMAL(5,2),
            humedad INT,
            presion INT,
            viento_kmh INT,
            condicion VARCHAR(100),
            fecha_registro TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        )
    """)
    conn.commit()
    print("✅ Tabla 'registros_clima' creada")
    cursor.close()
    conn.close()

def obtener_clima(ciudad="Buenos Aires"):
    url = f"https://wttr.in/{ciudad}?format=j1"
    print(f"🌍 Consultando clima para {ciudad}...")
    
    response = requests.get(url)
    
    if response.status_code == 200:
        data = response.json()
        current = data["current_condition"][0]
        
        return {
            'ciudad': ciudad,
            'temperatura': float(current["temp_C"]),
            'humedad': int(current["humidity"]),
            'presion': int(current["pressure"]),
            'viento_kmh': int(current["windspeedKmph"]),
            'condicion': current["weatherDesc"][0]["value"]
        }
    return None

def guardar_clima(datos_clima):
    conn = mysql.connector.connect(**DB_CONFIG)
    cursor = conn.cursor()
    
    sql = """
        INSERT INTO registros_clima 
        (ciudad, temperatura_celsius, humedad, presion, viento_kmh, condicion)
        VALUES (%s, %s, %s, %s, %s, %s)
    """
    values = (datos_clima['ciudad'], datos_clima['temperatura'], 
              datos_clima['humedad'], datos_clima['presion'],
              datos_clima['viento_kmh'], datos_clima['condicion'])
    
    cursor.execute(sql, values)
    conn.commit()
    
    print(f"✅ Clima guardado: {datos_clima['temperatura']}°C | {datos_clima['condicion']}")
    
    cursor.close()
    conn.close()

def historial_clima(ciudad, limite=5):
    conn = mysql.connector.connect(**DB_CONFIG)
    cursor = conn.cursor(dictionary=True)
    
    cursor.execute("""
        SELECT * FROM registros_clima 
        WHERE ciudad = %s 
        ORDER BY fecha_registro DESC 
        LIMIT %s
    """, (ciudad, limite))
    
    registros = cursor.fetchall()
    cursor.close()
    conn.close()
    return registros

if __name__ == "__main__":
    crear_tabla_clima()
    
    # Registrar clima actual
    clima = obtener_clima("Madrid")
    if clima:
        guardar_clima(clima)
    
    # Ver histórico
    print("\n=== Histórico Madrid ===")
    historico = historial_clima("Madrid", 3)
    for reg in historico:
        print(f"{reg['fecha_registro']}: {reg['temperatura_celsius']}°C - {reg['condicion']}")
```
### 08_dolar_historico.py
```python
"""
Ejercicio 8: API de cotización dólar + tabla de histórico
Archivo: 08_dolar_historico.py
API: DolarAPI
Objetivo: Acumular valores diarios para análisis
"""
from config import DB_CONFIG
import requests
import mysql.connector
from datetime import date

def crear_tabla_dolar():
    conn = mysql.connector.connect(**DB_CONFIG)
    cursor = conn.cursor()
    
    cursor.execute("""
        CREATE TABLE IF NOT EXISTS cotizaciones_dolar (
            id INT AUTO_INCREMENT PRIMARY KEY,
            tipo VARCHAR(50),
            compra DECIMAL(10,2),
            venta DECIMAL(10,2),
            fecha DATE,
            fuente VARCHAR(100),
            UNIQUE KEY unique_daily (tipo, fecha)
        )
    """)
    conn.commit()
    print("✅ Tabla 'cotizaciones_dolar' creada")
    cursor.close()
    conn.close()

def obtener_todas_cotizaciones():
    """Obtener todos los tipos de cambio disponibles"""
    url = "https://dolarapi.com/v1/dolares"
    response = requests.get(url)
    
    if response.status_code == 200:
        return response.json()
    return []

def guardar_cotizacion(cotizacion):
    conn = mysql.connector.connect(**DB_CONFIG)
    cursor = conn.cursor()
    
    sql = """
        INSERT INTO cotizaciones_dolar (tipo, compra, venta, fecha, fuente)
        VALUES (%s, %s, %s, %s, %s)
        ON DUPLICATE KEY UPDATE
        compra = VALUES(compra), venta = VALUES(venta)
    """
    values = (cotizacion['casa'], cotizacion['compra'], 
              cotizacion['venta'], date.today(), 'dolarapi.com')
    
    cursor.execute(sql, values)
    conn.commit()
    
    cursor.close()
    conn.close()

def obtener_evolucion(tipo='blue', dias=7):
    conn = mysql.connector.connect(**DB_CONFIG)
    cursor = conn.cursor(dictionary=True)
    
    cursor.execute("""
        SELECT fecha, compra, venta
        FROM cotizaciones_dolar
        WHERE tipo = %s
        ORDER BY fecha DESC
        LIMIT %s
    """, (tipo, dias))
    
    resultados = cursor.fetchall()
    cursor.close()
    conn.close()
    return resultados

if __name__ == "__main__":
    crear_tabla_dolar()
    
    print("📊 Consultando cotizaciones del dólar...")
    cotizaciones = obtener_todas_cotizaciones()
    
    for cotizacion in cotizaciones:
        guardar_cotizacion(cotizacion)
        print(f"  💵 {cotizacion['casa']}: ${cotizacion['venta']}")
    
    print("\n📈 Evolución últimos 5 días (blue):")
    evolucion = obtener_evolucion('blue', 5)
    for reg in evolucion:
        print(f"  {reg['fecha']}: Compra ${reg['compra']} | Venta ${reg['venta']}")
```
### 09_actualizar_company.py
```python
"""
Ejercicio 9: Actualizar tabla usando datos de múltiples APIs
Archivo: 09_actualizar_company.py
Objetivo: Enriquecer datos locales con información externa
"""
from config import DB_CONFIG
import requests
import mysql.connector

def agregar_columnas_company():
    conn = mysql.connector.connect(**DB_CONFIG)
    cursor = conn.cursor()
    
    # Agregar columnas si no existen
    columnas = [
        ("company_name", "VARCHAR(200)"),
        ("company_catchphrase", "VARCHAR(300)"),
        ("company_bs", "VARCHAR(200)")
    ]
    
    for col_name, col_type in columnas:
        try:
            cursor.execute(f"ALTER TABLE usuarios ADD COLUMN {col_name} {col_type}")
            print(f"✅ Columna {col_name} agregada")
        except mysql.connector.Error as e:
            if "Duplicate column" in str(e):
                print(f"ℹ️ Columna {col_name} ya existe")
            else:
                print(f"Error: {e}")
    
    conn.commit()
    cursor.close()
    conn.close()

def actualizar_datos_empresa():
    url = "https://jsonplaceholder.typicode.com/users"
    response = requests.get(url)
    usuarios = response.json()
    
    conn = mysql.connector.connect(**DB_CONFIG)
    cursor = conn.cursor()
    
    sql = """
        UPDATE usuarios 
        SET company_name = %s, company_catchphrase = %s, company_bs = %s
        WHERE id = %s
    """
    
    for user in usuarios:
        company = user['company']
        cursor.execute(sql, (
            company['name'],
            company['catchPhrase'],
            company['bs'],
            user['id']
        ))
    
    conn.commit()
    print(f"✅ Actualizadas empresas de {len(usuarios)} usuarios")
    
    cursor.close()
    conn.close()

def ver_empresas():
    conn = mysql.connector.connect(**DB_CONFIG)
    cursor = conn.cursor(dictionary=True)
    
    cursor.execute("""
        SELECT id, name, company_name, company_catchphrase
        FROM usuarios
        WHERE company_name IS NOT NULL
        LIMIT 5
    """)
    
    empresas = cursor.fetchall()
    cursor.close()
    conn.close()
    
    for emp in empresas:
        print(f"🏢 {emp['name']} → {emp['company_name']}")
        print(f"   Frase: {emp['company_catchphrase'][:60]}...")
        print()

if __name__ == "__main__":
    agregar_columnas_company()
    actualizar_datos_empresa()
    ver_empresas()
```
### 10_exportar_json_backup.py
```python
"""
Ejercicio 10: Exportar datos de MySQL a JSON (backup)
Archivo: 10_exportar_json_backup.py
Objetivo: Crear respaldo portátil de datos relacionales
"""
from config import DB_CONFIG
import mysql.connector
import json
import os
from datetime import datetime

def exportar_tabla_a_json(tabla, archivo_salida=None):
    if not archivo_salida:
        archivo_salida = f"backup_{tabla}_{datetime.now().strftime('%Y%m%d_%H%M%S')}.json"
    
    conn = mysql.connector.connect(**DB_CONFIG)
    cursor = conn.cursor(dictionary=True)
    
    cursor.execute(f"SELECT * FROM {tabla}")
    datos = cursor.fetchall()
    
    # Convertir fechas/datetime a string
    for registro in datos:
        for key, value in registro.items():
            if hasattr(value, 'isoformat'):
                registro[key] = value.isoformat()
            elif isinstance(value, bytes):
                registro[key] = value.decode('utf-8')
    
    with open(archivo_salida, 'w', encoding='utf-8') as f:
        json.dump(datos, f, indent=2, ensure_ascii=False, default=str)
    
    print(f"✅ Exportados {len(datos)} registros de '{tabla}' a {archivo_salida}")
    
    cursor.close()
    conn.close()
    return archivo_salida

def importar_json_a_tabla(tabla, archivo_json, limpiar_primero=False):
    if not os.path.exists(archivo_json):
        print(f"❌ Archivo no encontrado: {archivo_json}")
        return 0
    
    with open(archivo_json, 'r', encoding='utf-8') as f:
        datos = json.load(f)
    
    if not datos:
        print("⚠️ Archivo JSON vacío")
        return 0
    
    conn = mysql.connector.connect(**DB_CONFIG)
    cursor = conn.cursor()
    
    if limpiar_primero:
        cursor.execute(f"TRUNCATE TABLE {tabla}")
        print(f"🗑️ Tabla {tabla} limpiada")
    
    columnas = list(datos[0].keys())
    placeholders = ', '.join(['%s'] * len(columnas))
    columnas_str = ', '.join(columnas)
    
    sql = f"INSERT INTO {tabla} ({columnas_str}) VALUES ({placeholders})"
    
    insertados = 0
    for registro in datos:
        valores = [registro.get(col) for col in columnas]
        try:
            cursor.execute(sql, valores)
            insertados += 1
        except mysql.connector.Error as e:
            if "Duplicate" not in str(e):
                print(f"Error insertando: {e}")
    
    conn.commit()
    print(f"✅ Importados {insertados}/{len(datos)} registros a '{tabla}'")
    
    cursor.close()
    conn.close()
    return insertados

def listar_tablas():
    conn = mysql.connector.connect(**DB_CONFIG)
    cursor = conn.cursor()
    
    cursor.execute("SHOW TABLES")
    tablas = [t[0] for t in cursor.fetchall()]
    
    cursor.close()
    conn.close()
    return tablas

if __name__ == "__main__":
    print("=== Tablas disponibles ===")
    tablas = listar_tablas()
    for t in tablas:
        print(f"  - {t}")
    
    # Exportar tabla usuarios
    archivo = exportar_tabla_a_json('usuarios')
    
    print(f"\n📦 Backup creado: {archivo}")
    print(f"Tamaño: {os.path.getsize(archivo)} bytes")
    
    # Para probar importación (descomentar si se desea)
    # importar_json_a_tabla('usuarios_copy', archivo)
```
### 🔹 Nivel 3 – APIs paginadas y bulk insert
11_api_paginada_lotes.py
```python
"""
Ejercicio 11: API paginada con inserción por lotes
Archivo: 11_api_paginada_lotes.py
API: Rick and Morty
Objetivo: Manejar grandes volúmenes de datos eficientemente
"""
from config import DB_CONFIG
import requests
import mysql.connector

def crear_tabla_personajes():
    conn = mysql.connector.connect(**DB_CONFIG)
    cursor = conn.cursor()
    
    cursor.execute("""
        CREATE TABLE IF NOT EXISTS personajes_rm (
            id INT PRIMARY KEY,
            name VARCHAR(100),
            status VARCHAR(50),
            species VARCHAR(100),
            gender VARCHAR(50),
            origin VARCHAR(100),
            location VARCHAR(100),
            image_url VARCHAR(255),
            episodios_count INT
        )
    """)
    conn.commit()
    print("✅ Tabla 'personajes_rm' creada")
    cursor.close()
    conn.close()

def guardar_personajes_lote(personajes):
    if not personajes:
        return 0
    
    conn = mysql.connector.connect(**DB_CONFIG)
    cursor = conn.cursor()
    
    sql = """
        INSERT INTO personajes_rm 
        (id, name, status, species, gender, origin, location, image_url, episodios_count)
        VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s)
        ON DUPLICATE KEY UPDATE
        name = VALUES(name), status = VALUES(status), species = VALUES(species)
    """
    
    valores = []
    for p in personajes:
        origin_name = p['origin']['name'] if p['origin'] else 'Unknown'
        location_name = p['location']['name'] if p['location'] else 'Unknown'
        valores.append((
            p['id'], p['name'], p['status'], p['species'], p['gender'],
            origin_name, location_name, p['image'], len(p['episode'])
        ))
    
    cursor.executemany(sql, valores)
    conn.commit()
    print(f"  💾 Lote guardado: {len(valores)} personajes")
    
    cursor.close()
    conn.close()
    return len(valores)

def sincronizar_todos_personajes():
    url = "https://rickandmortyapi.com/api/character"
    lote = []
    total_guardados = 0
    pagina = 1
    
    print("🔄 Sincronizando personajes de Rick and Morty...")
    
    while url:
        print(f"  Procesando página {pagina}...")
        response = requests.get(url)
        data = response.json()
        
        lote.extend(data['results'])
        
        # Guardar cada 30 personajes
        if len(lote) >= 30:
            total_guardados += guardar_personajes_lote(lote)
            lote = []
        
        url = data['info']['next']
        pagina += 1
    
    # Guardar restantes
    if lote:
        total_guardados += guardar_personajes_lote(lote)
    
    print(f"\n✅ Sincronización completa: {total_guardados} personajes guardados")
    return total_guardados

def estadisticas_personajes():
    conn = mysql.connector.connect(**DB_CONFIG)
    cursor = conn.cursor(dictionary=True)
    
    cursor.execute("""
        SELECT 
            COUNT(*) as total,
            COUNT(DISTINCT species) as especies,
            AVG(episodios_count) as promedio_episodios
        FROM personajes_rm
    """)
    
    stats = cursor.fetchone()
    cursor.close()
    conn.close()
    return stats

if __name__ == "__main__":
    crear_tabla_personajes()
    sincronizar_todos_personajes()
    
    stats = estadisticas_personajes()
    print(f"\n📊 Estadísticas:")
    print(f"  Total personajes: {stats['total']}")
    print(f"  Especies distintas: {stats['especies']}")
    print(f"  Promedio episodios: {stats['promedio_episodios']:.1f}")
```
12_filtros_parametrizados.py
```python
"""
Ejercicio 12: Combinar filtros de API con WHERE de MySQL
Archivo: 12_filtros_parametrizados.py
Objetivo: Evitar SQL injection con consultas parametrizadas
"""
from config import DB_CONFIG
import requests
import mysql.connector

def buscar_posts_api_por_usuario(user_id):
    """Obtener posts de un usuario específico desde API"""
    url = f"https://jsonplaceholder.typicode.com/posts?userId={user_id}"
    response = requests.get(url)
    return response.json()

def guardar_posts_usuario(posts, user_id):
    """Guardar posts verificando que no existan previamente"""
    conn = mysql.connector.connect(**DB_CONFIG)
    cursor = conn.cursor()
    
    # Verificar si ya existen posts para este usuario (parametrizado)
    cursor.execute("SELECT COUNT(*) FROM posts WHERE user_id = %s", (user_id,))
    count = cursor.fetchone()[0]
    
    if count > 0:
        print(f"⚠️ Usuario {user_id} ya tiene {count} posts guardados")
        opcion = input("¿Actualizar? (s/n): ").lower()
        if opcion != 's':
            cursor.close()
            conn.close()
            return 0
    
    # Insertar posts (parametrizado para evitar injection)
    sql = "INSERT IGNORE INTO posts (id, user_id, title, body) VALUES (%s, %s, %s, %s)"
    for post in posts:
        cursor.execute(sql, (post['id'], post['userId'], post['title'], post['body']))
    
    conn.commit()
    print(f"✅ Guardados {len(posts)} posts para usuario {user_id}")
    
    cursor.close()
    conn.close()
    return len(posts)

def buscar_posts_mysql(filtros):
    """
    Búsqueda parametrizada en MySQL
    filtros: dict con 'user_id', 'titulo_contiene', 'limit'
    """
    conn = mysql.connector.connect(**DB_CONFIG)
    cursor = conn.cursor(dictionary=True)
    
    query = "SELECT * FROM posts WHERE 1=1"
    params = []
    
    if filtros.get('user_id'):
        query += " AND user_id = %s"
        params.append(filtros['user_id'])
    
    if filtros.get('titulo_contiene'):
        query += " AND title LIKE %s"
        params.append(f"%{filtros['titulo_contiene']}%")
    
    query += " ORDER BY id DESC"
    
    if filtros.get('limit'):
        query += " LIMIT %s"
        params.append(filtros['limit'])
    
    print(f"\n🔍 Consulta SQL: {query}")
    print(f"📎 Parámetros: {params}")
    
    cursor.execute(query, params)
    resultados = cursor.fetchall()
    
    cursor.close()
    conn.close()
    return resultados

if __name__ == "__main__":
    # Probar búsqueda parametrizada segura
    print("=== Búsqueda segura por usuario ===")
    filtros = {'user_id': 2, 'limit': 5}
    resultados = buscar_posts_mysql(filtros)
    
    for r in resultados:
        print(f"  [{r['user_id']}] {r['title'][:50]}")
    
    # Búsqueda por texto
    print("\n=== Búsqueda por texto ===")
    filtros2 = {'titulo_contiene': 'quidem', 'limit': 3}
    resultados2 = buscar_posts_mysql(filtros2)
    
    for r in resultados2:
        print(f"  {r['title'][:60]}")
```
13_columna_json_mysql.py
```python
"""
Ejercicio 13: Usar tipo JSON de MySQL (MySQL 5.7+)
Archivo: 13_columna_json_mysql.py
Objetivo: Guardar respuesta completa de API como JSON
"""
from config import DB_CONFIG
import requests
import mysql.connector
import json

def crear_tabla_con_json():
    conn = mysql.connector.connect(**DB_CONFIG)
    cursor = conn.cursor()
    
    cursor.execute("""
        CREATE TABLE IF NOT EXISTS api_responses_cache (
            id INT AUTO_INCREMENT PRIMARY KEY,
            endpoint VARCHAR(255),
            response_json JSON,
            status_code INT,
            tiempo_ms INT,
            fecha_consulta TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            UNIQUE KEY unique_endpoint (endpoint)
        )
    """)
    conn.commit()
    print("✅ Tabla 'api_responses_cache' con columna JSON")
    cursor.close()
    conn.close()

def guardar_response_json(endpoint, data, status_code, tiempo_ms):
    conn = mysql.connector.connect(**DB_CONFIG)
    cursor = conn.cursor()
    
    # Convertir dict a string JSON
    json_str = json.dumps(data, ensure_ascii=False)
    
    sql = """
        INSERT INTO api_responses_cache (endpoint, response_json, status_code, tiempo_ms)
        VALUES (%s, %s, %s, %s)
        ON DUPLICATE KEY UPDATE
        response_json = VALUES(response_json),
        status_code = VALUES(status_code),
        tiempo_ms = VALUES(tiempo_ms),
        fecha_consulta = CURRENT_TIMESTAMP
    """
    
    cursor.execute(sql, (endpoint, json_str, status_code, tiempo_ms))
    conn.commit()
    print(f"✅ Guardado JSON de {endpoint}")
    
    cursor.close()
    conn.close()

def leer_campo_json(endpoint, campo_json):
    """Extraer campo específico de JSON almacenado usando JSON_EXTRACT"""
    conn = mysql.connector.connect(**DB_CONFIG)
    cursor = conn.cursor()
    
    query = f"""
        SELECT JSON_EXTRACT(response_json, '$.{campo_json}') as valor
        FROM api_responses_cache
        WHERE endpoint = %s
    """
    
    cursor.execute(query, (endpoint,))
    resultado = cursor.fetchone()
    
    cursor.close()
    conn.close()
    
    if resultado and resultado[0]:
        # Quitar comillas del resultado JSON
        return resultado[0].strip('"')
    return None

def buscar_en_json(patron):
    """Buscar en todo el JSON almacenado"""
    conn = mysql.connector.connect(**DB_CONFIG)
    cursor = conn.cursor(dictionary=True)
    
    query = """
        SELECT endpoint, 
               JSON_SEARCH(response_json, 'all', %s) as encontrado
        FROM api_responses_cache
        WHERE JSON_SEARCH(response_json, 'one', %s) IS NOT NULL
    """
    
    cursor.execute(query, (patron, patron))
    resultados = cursor.fetchall()
    
    cursor.close()
    conn.close()
    return resultados

if __name__ == "__main__":
    import time
    
    crear_tabla_con_json()
    
    # Guardar varias respuestas de API como JSON
    endpoints = [
        "https://dolarapi.com/v1/dolares/blue",
        "https://jsonplaceholder.typicode.com/posts/1",
        "https://api.github.com/users/octocat"
    ]
    
    for url in endpoints:
        inicio = time.time()
        response = requests.get(url)
        tiempo_ms = int((time.time() - inicio) * 1000)
        
        if response.status_code == 200:
            guardar_response_json(url, response.json(), response.status_code, tiempo_ms)
    
    # Leer campos específicos del JSON
    print("\n=== Extrayendo datos del JSON ===")
    venta = leer_campo_json("https://dolarapi.com/v1/dolares/blue", "venta")
    print(f"Dólar venta: ${venta}")
    
    titulo = leer_campo_json("https://jsonplaceholder.typicode.com/posts/1", "title")
    print(f"Título post: {titulo}")
```
14_pokemon_normalizado.py
```python
"""
Ejercicio 14: Normalizar datos anidados de API en múltiples tablas
Archivo: 14_pokemon_normalizado.py
API: PokéAPI
Objetivo: Modelar datos complejos en estructura relacional
"""
from config import DB_CONFIG
import requests
import mysql.connector

def crear_tablas_pokemon():
    conn = mysql.connector.connect(**DB_CONFIG)
    cursor = conn.cursor()
    
    # Tabla principal de Pokémon
    cursor.execute("""
        CREATE TABLE IF NOT EXISTS pokemon (
            id INT PRIMARY KEY,
            name VARCHAR(100),
            height INT,
            weight INT,
            base_experience INT,
            order_num INT
        )
    """)
    
    # Tabla de tipos (many-to-many)
    cursor.execute("""
        CREATE TABLE IF NOT EXISTS pokemon_types (
            pokemon_id INT,
            type_name VARCHAR(50),
            slot INT,
            FOREIGN KEY (pokemon_id) REFERENCES pokemon(id) ON DELETE CASCADE,
            PRIMARY KEY (pokemon_id, type_name)
        )
    """)
    
    # Tabla de habilidades
    cursor.execute("""
        CREATE TABLE IF NOT EXISTS pokemon_abilities (
            pokemon_id INT,
            ability_name VARCHAR(100),
            is_hidden BOOLEAN,
            slot INT,
            FOREIGN KEY (pokemon_id) REFERENCES pokemon(id) ON DELETE CASCADE,
            PRIMARY KEY (pokemon_id, ability_name)
        )
    """)
    
    # Tabla de estadísticas base
    cursor.execute("""
        CREATE TABLE IF NOT EXISTS pokemon_stats (
            pokemon_id INT,
            stat_name VARCHAR(50),
            base_stat INT,
            effort INT,
            FOREIGN KEY (pokemon_id) REFERENCES pokemon(id) ON DELETE CASCADE,
            PRIMARY KEY (pokemon_id, stat_name)
        )
    """)
    
    conn.commit()
    print("✅ Tablas Pokémon normalizadas creadas")
    cursor.close()
    conn.close()

def guardar_pokemon_completo(name_or_id):
    url = f"https://pokeapi.co/api/v2/pokemon/{str(name_or_id).lower()}"
    print(f"🔍 Consultando Pokémon: {name_or_id}")
    
    response = requests.get(url)
    if response.status_code != 200:
        print(f"❌ No se encontró {name_or_id}")
        return False
    
    data = response.json()
    
    conn = mysql.connector.connect(**DB_CONFIG)
    cursor = conn.cursor()
    
    try:
        conn.start_transaction()
        
        # 1. Insertar Pokémon principal
        sql_pokemon = """
            INSERT INTO pokemon (id, name, height, weight, base_experience, order_num)
            VALUES (%s, %s, %s, %s, %s, %s)
            ON DUPLICATE KEY UPDATE
            name = VALUES(name), height = VALUES(height), weight = VALUES(weight)
        """
        cursor.execute(sql_pokemon, (
            data['id'], data['name'], data['height'], 
            data['weight'], data['base_experience'], data['order']
        ))
        
        # 2. Insertar tipos
        sql_type = "INSERT IGNORE INTO pokemon_types (pokemon_id, type_name, slot) VALUES (%s, %s, %s)"
        for type_info in data['types']:
            cursor.execute(sql_type, (data['id'], type_info['type']['name'], type_info['slot']))
        
        # 3. Insertar habilidades
        sql_ability = """
            INSERT INTO pokemon_abilities (pokemon_id, ability_name, is_hidden, slot)
            VALUES (%s, %s, %s, %s)
            ON DUPLICATE KEY UPDATE is_hidden = VALUES(is_hidden)
        """
        for ability_info in data['abilities']:
            cursor.execute(sql_ability, (
                data['id'], ability_info['ability']['name'],
                ability_info['is_hidden'], ability_info['slot']
            ))
        
        # 4. Insertar estadísticas
        sql_stat = """
            INSERT INTO pokemon_stats (pokemon_id, stat_name, base_stat, effort)
            VALUES (%s, %s, %s, %s)
            ON DUPLICATE KEY UPDATE base_stat = VALUES(base_stat)
        """
        for stat_info in data['stats']:
            cursor.execute(sql_stat, (
                data['id'], stat_info['stat']['name'],
                stat_info['base_stat'], stat_info['effort']
            ))
        
        conn.commit()
        print(f"✅ Pokémon {data['name'].upper()} guardado correctamente")
        
        # Mostrar resumen
        tipos = [t['type']['name'] for t in data['types']]
        print(f"   Tipos: {', '.join(tipos)}")
        print(f"   Altura: {data['height']/10}m | Peso: {data['weight']/10}kg")
        
        return True
        
    except Exception as e:
        conn.rollback()
        print(f"❌ Error guardando {name_or_id}: {e}")
        return False
    finally:
        cursor.close()
        conn.close()

def consultar_pokemon_completo(pokemon_id):
    conn = mysql.connector.connect(**DB_CONFIG)
    cursor = conn.cursor(dictionary=True)
    
    # Obtener datos básicos
    cursor.execute("SELECT * FROM pokemon WHERE id = %s", (pokemon_id,))
    pokemon = cursor.fetchone()
    
    if not pokemon:
        return None
    
    # Obtener tipos
    cursor.execute("SELECT type_name FROM pokemon_types WHERE pokemon_id = %s", (pokemon_id,))
    pokemon['tipos'] = [t['type_name'] for t in cursor.fetchall()]
    
    # Obtener habilidades
    cursor.execute("SELECT ability_name, is_hidden FROM pokemon_abilities WHERE pokemon_id = %s", (pokemon_id,))
    pokemon['habilidades'] = cursor.fetchall()
    
    # Obtener estadísticas
    cursor.execute("SELECT stat_name, base_stat FROM pokemon_stats WHERE pokemon_id = %s", (pokemon_id,))
    pokemon['estadisticas'] = cursor.fetchall()
    
    cursor.close()
    conn.close()
    return pokemon

if __name__ == "__main__":
    crear_tablas_pokemon()
    
    # Guardar varios Pokémon
    pokemons = ["pikachu", "charizard", "bulbasaur", "mewtwo"]
    
    for p in pokemons:
        guardar_pokemon_completo(p)
        print()
    
    # Consultar un Pokémon desde BD
    print("=== Consulta desde MySQL ===")
    pikachu = consultar_pokemon_completo(25)
    if pikachu:
        print(f"⚡ {pikachu['name'].upper()}")
        print(f"   Tipos: {', '.join(pikachu['tipos'])}")
        print(f"   Estadísticas:")
        for stat in pikachu['estadisticas']:
            print(f"     - {stat['stat_name']}: {stat['base_stat']}")
```
15_logs_api_mysql.py
```python
"""
Ejercicio 15: Registrar logs de consumo de API en tabla
Archivo: 15_logs_api_mysql.py
Objetivo: Auditar todas las llamadas a API
"""
from config import DB_CONFIG
import requests
import mysql.connector
import time
import hashlib
import traceback
from datetime import datetime

def crear_tabla_logs_api():
    conn = mysql.connector.connect(**DB_CONFIG)
    cursor = conn.cursor()
    
    cursor.execute("""
        CREATE TABLE IF NOT EXISTS api_call_log (
            id INT AUTO_INCREMENT PRIMARY KEY,
            endpoint VARCHAR(500),
            metodo VARCHAR(10),
            status_code INT,
            respuesta_tiempo_ms INT,
            bytes_recibidos INT,
            error_msg TEXT,
            hash_request VARCHAR(64),
            timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            INDEX idx_endpoint (endpoint(100)),
            INDEX idx_status (status_code),
            INDEX idx_fecha (timestamp)
        )
    """)
    conn.commit()
    print("✅ Tabla 'api_call_log' creada")
    cursor.close()
    conn.close()

def registrar_log(endpoint, metodo, status_code, tiempo_ms, bytes_recibidos=0, 
                  error_msg=None, request_data=None):
    conn = mysql.connector.connect(**DB_CONFIG)
    cursor = conn.cursor()
    
    hash_val = None
    if request_data:
        hash_val = hashlib.sha256(str(request_data).encode()).hexdigest()[:64]
    
    sql = """
        INSERT INTO api_call_log 
        (endpoint, metodo, status_code, respuesta_tiempo_ms, bytes_recibidos, error_msg, hash_request)
        VALUES (%s, %s, %s, %s, %s, %s, %s)
    """
    cursor.execute(sql, (endpoint, metodo, status_code, tiempo_ms, 
                        bytes_recibidos, error_msg, hash_val))
    conn.commit()
    
    cursor.close()
    conn.close()

def api_con_log(url, metodo='GET', data=None, timeout=10):
    inicio = time.time()
    bytes_recibidos = 0
    status_code = 0
    
    try:
        if metodo == 'GET':
            response = requests.get(url, timeout=timeout)
        else:
            response = requests.post(url, json=data, timeout=timeout)
        
        tiempo_ms = int((time.time() - inicio) * 1000)
        bytes_recibidos = len(response.content)
        status_code = response.status_code
        
        if response.status_code >= 400:
            error_msg = f"HTTP {response.status_code}"
        else:
            error_msg = None
        
        registrar_log(url, metodo, response.status_code, tiempo_ms, 
                     bytes_recibidos, error_msg, data)
        
        response.raise_for_status()
        return response.json()
        
    except requests.exceptions.Timeout as e:
        tiempo_ms = int((time.time() - inicio) * 1000)
        registrar_log(url, metodo, 0, tiempo_ms, 0, f"Timeout: {e}", data)
        print(f"⏰ Timeout registrado en log")
        return None
        
    except Exception as e:
        tiempo_ms = int((time.time() - inicio) * 1000)
        error_completo = f"{type(e).__name__}: {str(e)}"
        registrar_log(url, metodo, status_code, tiempo_ms, bytes_recibidos, error_completo, data)
        print(f"❌ Error registrado en log: {error_completo}")
        return None

def estadisticas_logs(horas=24):
    conn = mysql.connector.connect(**DB_CONFIG)
    cursor = conn.cursor(dictionary=True)
    
    query = """
        SELECT 
            COUNT(*) as total_llamadas,
            AVG(respuesta_tiempo_ms) as tiempo_promedio_ms,
            SUM(CASE WHEN status_code >= 400 OR error_msg IS NOT NULL THEN 1 ELSE 0 END) as errores,
            COUNT(DISTINCT endpoint) as endpoints_distintos
        FROM api_call_log
        WHERE timestamp > DATE_SUB(NOW(), INTERVAL %s HOUR)
    """
    
    cursor.execute(query, (horas,))
    stats = cursor.fetchone()
    
    cursor.close()
    conn.close()
    return stats

def errores_recientes(limite=10):
    conn = mysql.connector.connect(**DB_CONFIG)
    cursor = conn.cursor(dictionary=True)
    
    cursor.execute("""
        SELECT endpoint, metodo, error_msg, timestamp, respuesta_tiempo_ms
        FROM api_call_log
        WHERE error_msg IS NOT NULL OR status_code >= 400
        ORDER BY timestamp DESC
        LIMIT %s
    """, (limite,))
    
    errores = cursor.fetchall()
    cursor.close()
    conn.close()
    return errores

if __name__ == "__main__":
    crear_tabla_logs_api()
    
    print("=== Probando API con logging ===")
    
    # Llamada exitosa
    print("\n1. Llamada exitosa:")
    resultado = api_con_log("https://jsonplaceholder.typicode.com/posts/1")
    if resultado:
        print(f"   ✅ Éxito: {resultado['title'][:40]}")
    
    # Llamada con timeout (simulado)
    print("\n2. Llamada lenta:")
    resultado = api_con_log("https://httpbin.org/delay/15", timeout=2)
    
    # Llamada a endpoint inexistente
    print("\n3. Llamada fallida:")
    resultado = api_con_log("https://jsonplaceholder.typicode.com/inexistente")
    
    # Estadísticas
    print("\n=== Estadísticas últimas 24 horas ===")
    stats = estadisticas_logs(24)
    print(f"  Total llamadas: {stats['total_llamadas']}")
    print(f"  Tiempo promedio: {stats['tiempo_promedio_ms']:.0f}ms")
    print(f"  Errores: {stats['errores']}")
    print(f"  Endpoints únicos: {stats['endpoints_distintos']}")
    
    print("\n=== Últimos errores ===")
    errores = errores_recientes(5)
    for err in errores:
        print(f"  [{err['timestamp']}] {err['endpoint'][:60]}")
        print(f"     Error: {err['error_msg']}")
```
🔸 Nivel 4 – Proyectos integradores
16_cache_mysql.py
```python
"""
Ejercicio 16: Sistema de caché persistente en MySQL
Archivo: 16_cache_mysql.py
Objetivo: Evitar llamadas repetidas a APIs costosas
"""
from config import DB_CONFIG
import requests
import mysql.connector
from datetime import datetime, timedelta
import json
import hashlib

def crear_tabla_cache():
    conn = mysql.connector.connect(**DB_CONFIG)
    cursor = conn.cursor()
    
    cursor.execute("""
        CREATE TABLE IF NOT EXISTS api_cache (
            cache_key VARCHAR(255) PRIMARY KEY,
            response_data LONGTEXT,
            fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            ttl_segundos INT DEFAULT 3600,
            hits INT DEFAULT 0
        )
    """)
    conn.commit()
    print("✅ Tabla 'api_cache' creada")
    cursor.close()
    conn.close()

def generar_cache_key(url, params=None):
    """Genera clave única para la cache"""
    key_str = url
    if params:
        key_str += json.dumps(params, sort_keys=True)
    return hashlib.md5(key_str.encode()).hexdigest()

def get_cached_or_fetch(url, ttl_segundos=3600, params=None):
    cache_key = generar_cache_key(url, params)
    
    conn = mysql.connector.connect(**DB_CONFIG)
    cursor = conn.cursor(dictionary=True)
    
    # Verificar cache
    cursor.execute("""
        SELECT response_data, fecha_creacion, hits
        FROM api_cache 
        WHERE cache_key = %s
    """, (cache_key,))
    
    cache_entry = cursor.fetchone()
    
    if cache_entry:
        fecha_cache = cache_entry['fecha_creacion']
        if datetime.now() - fecha_cache < timedelta(seconds=ttl_segundos):
            print(f"📦 CACHE HIT: {url[:60]}...")
            # Incrementar contador de hits
            cursor.execute("UPDATE api_cache SET hits = hits + 1 WHERE cache_key = %s", (cache_key,))
            conn.commit()
            
            cursor.close()
            conn.close()
            return json.loads(cache_entry['response_data'])
        else:
            print(f"⏰ CACHE EXPIRADA: {url[:60]}...")
    
    # Si no hay cache válido, llamar a la API
    print(f"🌐 API CALL: {url[:60]}...")
    
    try:
        response = requests.get(url, params=params, timeout=10)
        
        if response.status_code == 200:
            data = response.json()
            
            # Guardar en cache
            sql = """
                INSERT INTO api_cache (cache_key, response_data, ttl_segundos, hits)
                VALUES (%s, %s, %s, %s)
                ON DUPLICATE KEY UPDATE
                response_data = VALUES(response_data),
                fecha_creacion = CURRENT_TIMESTAMP,
                ttl_segundos = VALUES(ttl_segundos)
            """
            cursor.execute(sql, (cache_key, json.dumps(data), ttl_segundos, 0))
            conn.commit()
            
            cursor.close()
            conn.close()
            return data
        
        cursor.close()
        conn.close()
        return None
        
    except Exception as e:
        print(f"❌ Error fetching: {e}")
        cursor.close()
        conn.close()
        return None

def estadisticas_cache():
    conn = mysql.connector.connect(**DB_CONFIG)
    cursor = conn.cursor(dictionary=True)
    
    cursor.execute("""
        SELECT 
            COUNT(*) as total_items,
            SUM(hits) as total_hits,
            AVG(hits) as promedio_hits,
            SUM(CASE WHEN TIMESTAMPDIFF(SECOND, fecha_creacion, NOW()) > ttl_segundos THEN 1 ELSE 0 END) as expirados
        FROM api_cache
    """)
    
    stats = cursor.fetchone()
    cursor.close()
    conn.close()
    return stats

if __name__ == "__main__":
    crear_tabla_cache()
    
    # Probar caché
    url = "https://jsonplaceholder.typicode.com/posts/1"
    
    print("=== Primera llamada (debe ir a API) ===")
    resultado1 = get_cached_or_fetch(url, ttl_segundos=30)
    
    print("\n=== Segunda llamada (debe usar caché) ===")
    resultado2 = get_cached_or_fetch(url, ttl_segundos=30)
    
    print("\n=== Tercera llamada (debe usar caché) ===")
    resultado3 = get_cached_or_fetch(url, ttl_segundos=30)
    
    print("\n=== Estadísticas de caché ===")
    stats = estadisticas_cache()
    print(f"  Items en caché: {stats['total_items']}")
    print(f"  Total hits: {stats['total_hits']}")
    print(f"  Promedio hits por item: {stats['promedio_hits']:.1f}")
    print(f"  Expirados: {stats['expirados']}")
```
17_sincronizacion_bidireccional.py
```python
"""
Ejercicio 17: Sincronización bidireccional API ↔ MySQL
Archivo: 17_sincronizacion_bidireccional.py
Objetivo: Detectar cambios y mantener consistencia
"""
from config import DB_CONFIG
import requests
import mysql.connector
from datetime import datetime

def crear_tabla_sync():
    conn = mysql.connector.connect(**DB_CONFIG)
    cursor = conn.cursor()
    
    cursor.execute("""
        CREATE TABLE IF NOT EXISTS productos_sync (
            id INT PRIMARY KEY,
            nombre VARCHAR(100),
            precio DECIMAL(10,2),
            stock INT,
            ultima_sync_api DATETIME,
            ultima_modificacion_local DATETIME,
            conflicto BOOLEAN DEFAULT FALSE
        )
    """)
    conn.commit()
    print("✅ Tabla 'productos_sync' creada")
    cursor.close()
    conn.close()

def obtener_productos_api():
    """Simular API de productos"""
    url = "https://jsonplaceholder.typicode.com/posts?_limit=10"
    response = requests.get(url)
    posts = response.json()
    
    productos = []
    for post in posts:
        productos.append({
            'id': post['id'],
            'nombre': post['title'][:50],
            'precio': round(post['id'] * 9.99, 2),
            'stock': post['id'] * 5
        })
    return productos

def sincronizar_desde_api():
    productos_api = obtener_productos_api()
    
    conn = mysql.connector.connect(**DB_CONFIG)
    cursor = conn.cursor()
    
    ahora = datetime.now()
    nuevos = 0
    actualizados = 0
    
    for prod in productos_api:
        # Verificar si existe y si hay conflicto
        cursor.execute("""
            SELECT ultima_modificacion_local, precio, stock 
            FROM productos_sync WHERE id = %s
        """, (prod['id'],))
        existente = cursor.fetchone()
        
        if not existente:
            # Insertar nuevo
            cursor.execute("""
                INSERT INTO productos_sync 
                (id, nombre, precio, stock, ultima_sync_api, ultima_modificacion_local)
                VALUES (%s, %s, %s, %s, %s, %s)
            """, (prod['id'], prod['nombre'], prod['precio'], prod['stock'], ahora, ahora))
            nuevos += 1
        else:
            # Verificar si hubo modificación local después de última sync
            if existente[0] > cursor.execute("SELECT ultima_sync_api FROM productos_sync WHERE id = %s", (prod['id'],)):
                # Conflicto: local modificado después de última sincronización
                cursor.execute("""
                    UPDATE productos_sync 
                    SET conflicto = TRUE 
                    WHERE id = %s
                """, (prod['id'],))
                actualizados += 1
            else:
                # Actualización normal
                cursor.execute("""
                    UPDATE productos_sync 
                    SET nombre = %s, precio = %s, stock = %s, ultima_sync_api = %s
                    WHERE id = %s
                """, (prod['nombre'], prod['precio'], prod['stock'], ahora, prod['id']))
                actualizados += 1
    
    conn.commit()
    print(f"✅ Sincronización: {nuevos} nuevos, {actualizados} actualizados")
    
    cursor.close()
    conn.close()

def actualizar_local(producto_id, nuevo_precio=None, nuevo_stock=None):
    """Simular modificación local"""
    conn = mysql.connector.connect(**DB_CONFIG)
    cursor = conn.cursor()
    
    updates = []
    params = []
    
    if nuevo_precio is not None:
        updates.append("precio = %s")
        params.append(nuevo_precio)
    if nuevo_stock is not None:
        updates.append("stock = %s")
        params.append(nuevo_stock)
    
    if updates:
        updates.append("ultima_modificacion_local = %s")
        params.append(datetime.now())
        params.append(producto_id)
        
        query = f"UPDATE productos_sync SET {', '.join(updates)} WHERE id = %s"
        cursor.execute(query, params)
        conn.commit()
        print(f"✅ Producto {producto_id} actualizado localmente")
    
    cursor.close()
    conn.close()

def resolver_conflictos():
    """Mostrar y resolver conflictos manualmente"""
    conn = mysql.connector.connect(**DB_CONFIG)
    cursor = conn.cursor(dictionary=True)
    
    cursor.execute("SELECT * FROM productos_sync WHERE conflicto = TRUE")
    conflictos = cursor.fetchall()
    
    if not conflictos:
        print("✅ Sin conflictos pendientes")
        return
    
    print(f"\n⚠️ {len(conflictos)} conflictos encontrados:")
    for c in conflictos:
        print(f"\n  Producto ID {c['id']}: {c['nombre']}")
        print(f"    Precio actual (API): ${c['precio']}")
        print(f"    Modificado localmente: {c['ultima_modificacion_local']}")
        
        # Resolver automáticamente: mantener versión local
        cursor.execute("""
            UPDATE productos_sync 
            SET conflicto = FALSE 
            WHERE id = %s
        """, (c['id'],))
        print(f"    ✅ Conflicto resuelto (manteniendo datos locales)")
    
    conn.commit()
    cursor.close()
    conn.close()

if __name__ == "__main__":
    crear_tabla_sync()
    
    print("=== Sincronización inicial ===")
    sincronizar_desde_api()
    
    print("\n=== Modificación local ===")
    actualizar_local(1, nuevo_precio=199.99)
    
    print("\n=== Nueva sincronización (detecta conflicto) ===")
    sincronizar_desde_api()
    
    print("\n=== Resolución de conflictos ===")
    resolver_conflictos()
```
18_webhook_simulado.py
```python
"""
Ejercicio 18: Webhook simulado - API que recibe datos y los guarda
Archivo: 18_webhook_simulado.py
Objetivo: Simular recepción de webhooks y almacenar en MySQL
"""
from config import DB_CONFIG
import requests
import mysql.connector
import json
from datetime import datetime
from flask import Flask, request, jsonify

# Nota: Para este ejercicio necesitas instalar Flask:
# pip install flask

app = Flask(__name__)

def crear_tabla_webhooks():
    conn = mysql.connector.connect(**DB_CONFIG)
    cursor = conn.cursor()
    
    cursor.execute("""
        CREATE TABLE IF NOT EXISTS webhook_events (
            id INT AUTO_INCREMENT PRIMARY KEY,
            event_type VARCHAR(100),
            payload JSON,
            received_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            source_ip VARCHAR(45),
            processed BOOLEAN DEFAULT FALSE
        )
    """)
    conn.commit()
    print("✅ Tabla 'webhook_events' creada")
    cursor.close()
    conn.close()

def guardar_webhook(event_type, payload, source_ip):
    conn = mysql.connector.connect(**DB_CONFIG)
    cursor = conn.cursor()
    
    payload_json = json.dumps(payload, ensure_ascii=False)
    
    sql = """
        INSERT INTO webhook_events (event_type, payload, source_ip)
        VALUES (%s, %s, %s)
    """
    cursor.execute(sql, (event_type, payload_json, source_ip))
    conn.commit()
    
    event_id = cursor.lastrowid
    cursor.close()
    conn.close()
    
    return event_id

@app.route('/webhook', methods=['POST'])
def webhook_receiver():
    """Endpoint para recibir webhooks"""
    event_type = request.headers.get('X-Event-Type', 'unknown')
    source_ip = request.remote_addr
    
    try:
        payload = request.get_json()
        if not payload:
            return jsonify({'error': 'Invalid JSON'}), 400
        
        event_id = guardar_webhook(event_type, payload, source_ip)
        print(f"📨 Webhook recibido: {event_type} (ID: {event_id})")
        
        return jsonify({
            'status': 'ok',
            'event_id': event_id,
            'message': 'Webhook received'
        }), 200
        
    except Exception as e:
        print(f"❌ Error: {e}")
        return jsonify({'error': str(e)}), 500

def enviar_webhook_simulado(url, event_type, payload):
    """Función para enviar webhooks de prueba"""
    headers = {'X-Event-Type': event_type, 'Content-Type': 'application/json'}
    response = requests.post(url, json=payload, headers=headers)
    return response

def ver_eventos_recientes(limite=10):
    conn = mysql.connector.connect(**DB_CONFIG)
    cursor = conn.cursor(dictionary=True)
    
    cursor.execute("""
        SELECT id, event_type, payload, received_at, source_ip
        FROM webhook_events
        ORDER BY received_at DESC
        LIMIT %s
    """, (limite,))
    
    eventos = cursor.fetchall()
    cursor.close()
    conn.close()
    return eventos

if __name__ == '__main__':
    crear_tabla_webhooks()
    
    print("""
    ⚡ Webhook Simulado
    
    Para probar:
    1. Ejecuta este script: python 18_webhook_simulado.py
    2. En otra terminal, ejecuta:
    
    import requests
    payload = {"user_id": 123, "action": "purchase", "amount": 99.99}
    requests.post("http://localhost:5000/webhook", 
                  json=payload, 
                  headers={"X-Event-Type": "user.purchase"})
    
    3. Los eventos se guardarán automáticamente en MySQL
    """)
    
    # Iniciar servidor Flask
    app.run(debug=True, port=5000)
```
19_dashboard_metricas.py
```python
"""
Ejercicio 19: Dashboard de métricas desde datos de API
Archivo: 19_dashboard_metricas.py
Objetivo: Mostrar estadísticas agregadas desde MySQL
"""
from config import DB_CONFIG
import mysql.connector
import json
from datetime import datetime, timedelta

def crear_tabla_metricas():
    """Crear tabla para almacenar métricas pre-calculadas"""
    conn = mysql.connector.connect(**DB_CONFIG)
    cursor = conn.cursor()
    
    cursor.execute("""
        CREATE TABLE IF NOT EXISTS metricas_diarias (
            fecha DATE PRIMARY KEY,
            total_posts INT,
            total_usuarios INT,
            posts_promedio_por_usuario DECIMAL(10,2),
            ultima_actualizacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        )
    """)
    conn.commit()
    cursor.close()
    conn.close()

def calcular_metricas_diarias():
    """Calcular métricas desde datos existentes"""
    conn = mysql.connector.connect(**DB_CONFIG)
    cursor = conn.cursor()
    
    # Contar posts totales
    cursor.execute("SELECT COUNT(*) FROM posts")
    total_posts = cursor.fetchone()[0]
    
    # Contar usuarios
    cursor.execute("SELECT COUNT(*) FROM usuarios")
    total_usuarios = cursor.fetchone()[0]
    
    # Promedio de posts por usuario
    promedio = total_posts / total_usuarios if total_usuarios > 0 else 0
    
    # Guardar métricas
    fecha_hoy = datetime.now().date()
    cursor.execute("""
        INSERT INTO metricas_diarias (fecha, total_posts, total_usuarios, posts_promedio_por_usuario)
        VALUES (%s, %s, %s, %s)
        ON DUPLICATE KEY UPDATE
        total_posts = VALUES(total_posts),
        total_usuarios = VALUES(total_usuarios),
        posts_promedio_por_usuario = VALUES(posts_promedio_por_usuario),
        ultima_actualizacion = CURRENT_TIMESTAMP
    """, (fecha_hoy, total_posts, total_usuarios, promedio))
    
    conn.commit()
    cursor.close()
    conn.close()
    
    return {
        'fecha': fecha_hoy,
        'total_posts': total_posts,
        'total_usuarios': total_usuarios,
        'promedio_posts': round(promedio, 2)
    }

def obtener_evolucion(dias=7):
    """Obtener evolución de métricas en los últimos días"""
    conn = mysql.connector.connect(**DB_CONFIG)
    cursor = conn.cursor(dictionary=True)
    
    cursor.execute("""
        SELECT * FROM metricas_diarias
        ORDER BY fecha DESC
        LIMIT %s
    """, (dias,))
    
    metricas = cursor.fetchall()
    cursor.close()
    conn.close()
    return metricas

def dashboard():
    """Mostrar dashboard completo"""
    print("\n" + "="*60)
    print("📊 DASHBOARD DE MÉTRICAS")
    print("="*60)
    
    # Métricas actuales
    actuales = calcular_metricas_diarias()
    print(f"\n📈 Resumen al {actuales['fecha']}:")
    print(f"   • Total posts: {actuales['total_posts']}")
    print(f"   • Total usuarios: {actuales['total_usuarios']}")
    print(f"   • Promedio posts/usuario: {actuales['promedio_posts']}")
    
    # Evolución
    print("\n📉 Evolución últimos 7 días:")
    evolucion = obtener_evolucion(7)
    for dia in evolucion:
        print(f"   {dia['fecha']}: {dia['total_posts']} posts | {dia['total_usuarios']} usuarios")
    
    # Top usuarios (desde datos existentes)
    conn = mysql.connector.connect(**DB_CONFIG)
    cursor = conn.cursor(dictionary=True)
    
    cursor.execute("""
        SELECT u.name, COUNT(p.id) as posts_count
        FROM usuarios u
        LEFT JOIN posts p ON u.id = p.user_id
        GROUP BY u.id
        ORDER BY posts_count DESC
        LIMIT 5
    """)
    
    top_usuarios = cursor.fetchall()
    
    print("\n🏆 Top 5 usuarios con más posts:")
    for i, user in enumerate(top_usuarios, 1):
        print(f"   {i}. {user['name']}: {user['posts_count']} posts")
    
    cursor.close()
    conn.close()
    
    print("\n" + "="*60)

if __name__ == "__main__":
    crear_tabla_metricas()
    dashboard()
```
20_proyecto_final_ventas.py
```python
"""
Ejercicio 20: Proyecto Final - Gestor de Ventas con API y MySQL
Archivo: 20_proyecto_final_ventas.py
Objetivo: Aplicación completa integrando todos los conceptos
"""
from config import DB_CONFIG
import requests
import mysql.connector
import json
import time
import logging
from datetime import datetime
from typing import Optional
from pydantic import BaseModel, Field, validator

# Configurar logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s',
    handlers=[
        logging.FileHandler("ventas.log"),
        logging.StreamHandler()
    ]
)

# ============ MODELO PYDANTIC ============
class Venta(BaseModel):
    id: Optional[int] = None
    producto: str = Field(..., min_length=1, max_length=100)
    cantidad: int = Field(..., gt=0, le=1000)
    precio_unitario: float = Field(..., gt=0)
    fecha: datetime = Field(default_factory=datetime.now)
    
    @validator('producto')
    def producto_no_vacio(cls, v):
        if not v.strip():
            raise ValueError('Producto no puede estar vacío')
        return v.strip()
    
    def total(self) -> float:
        return self.cantidad * self.precio_unitario

# ============ BASE DE DATOS ============
def crear_tabla_ventas():
    conn = mysql.connector.connect(**DB_CONFIG)
    cursor = conn.cursor()
    
    cursor.execute("""
        CREATE TABLE IF NOT EXISTS ventas (
            id INT AUTO_INCREMENT PRIMARY KEY,
            producto VARCHAR(100),
            cantidad INT,
            precio_unitario DECIMAL(10,2),
            total DECIMAL(10,2),
            fecha TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        )
    """)
    conn.commit()
    print("✅ Tabla 'ventas' creada")
    cursor.close()
    conn.close()

def agregar_venta(venta: Venta):
    conn = mysql.connector.connect(**DB_CONFIG)
    cursor = conn.cursor()
    
    sql = """
        INSERT INTO ventas (producto, cantidad, precio_unitario, total)
        VALUES (%s, %s, %s, %s)
    """
    values = (venta.producto, venta.cantidad, venta.precio_unitario, venta.total())
    
    cursor.execute(sql, values)
    conn.commit()
    
    venta_id = cursor.lastrowid
    cursor.close()
    conn.close()
    
    logging.info(f"Venta agregada: ID={venta_id}, Producto={venta.producto}, Total=${venta.total():.2f}")
    return venta_id

def listar_ventas(limite=50):
    conn = mysql.connector.connect(**DB_CONFIG)
    cursor = conn.cursor(dictionary=True)
    
    cursor.execute("""
        SELECT * FROM ventas 
        ORDER BY fecha DESC 
        LIMIT %s
    """, (limite,))
    
    ventas = cursor.fetchall()
    cursor.close()
    conn.close()
    return ventas

def total_ventas():
    conn = mysql.connector.connect(**DB_CONFIG)
    cursor = conn.cursor()
    
    cursor.execute("SELECT COUNT(*), SUM(total) FROM ventas")
    count, total = cursor.fetchone()
    
    cursor.close()
    conn.close()
    return count or 0, total or 0.0

# ============ API DÓLAR ============
def obtener_dolar_con_reintentos(max_intentos=3):
    url = "https://dolarapi.com/v1/dolares/blue"
    
    for intento in range(max_intentos):
        try:
            logging.info(f"Consultando API dólar - Intento {intento+1}")
            response = requests.get(url, timeout=5)
            response.raise_for_status()
            
            data = response.json()
            logging.info(f"Dólar obtenido: Compra=${data['compra']} | Venta=${data['venta']}")
            return data
            
        except requests.exceptions.RequestException as e:
            logging.warning(f"Error en intento {intento+1}: {e}")
            if intento < max_intentos - 1:
                time.sleep(2 ** intento)
    
    logging.error("No se pudo obtener cotización del dólar")
    return None

def guardar_cotizacion_cache(cotizacion):
    """Guardar cotización para usar offline"""
    with open("dolar_cache.json", "w") as f:
        json.dump({
            'cotizacion': cotizacion,
            'fecha': datetime.now().isoformat()
        }, f)

def cargar_cotizacion_cache():
    try:
        with open("dolar_cache.json", "r") as f:
            return json.load(f)
    except:
        return None

# ============ CONVERSIÓN ============
def convertir_a_dolares(monto_ars, cotizacion):
    if cotizacion and cotizacion.get('venta'):
        return round(monto_ars / cotizacion['venta'], 2)
    return None

# ============ MENÚ PRINCIPAL ============
def menu():
    print("\n" + "="*50)
    print("🏪 GESTOR DE VENTAS IMBATIBLE")
    print("="*50)
    print("1. Agregar venta")
    print("2. Ver todas las ventas")
    print("3. Ver resumen (ARS y USD)")
    print("4. Estadísticas avanzadas")
    print("5. Salir")
    print("="*50)

def ver_ventas_con_usd():
    ventas = listar_ventas()
    
    if not ventas:
        print("\n📭 No hay ventas registradas")
        return
    
    # Obtener cotización
    cotizacion = obtener_dolar_con_reintentos()
    if not cotizacion:
        print("\n⚠️ Sin conexión a API - usando valores sin conversión a USD")
        cotizacion = None
    
    print("\n" + "="*80)
    print(f"{'ID':<5} {'Producto':<30} {'Cant.':<8} {'Precio':<12} {'Total ARS':<15} {'Total USD':<12}")
    print("-"*80)
    
    for v in ventas:
        total_usd = convertir_a_dolares(v['total'], cotizacion) if cotizacion else "N/A"
        usd_str = f"${total_usd}" if total_usd != "N/A" else "N/A"
        
        print(f"{v['id']:<5} {v['producto']:<30} {v['cantidad']:<8} "
              f"${v['precio_unitario']:<11.2f} ${v['total']:<14.2f} {usd_str:<12}")
    
    print("="*80)

def estadisticas():
    count, total_ars = total_ventas()
    
    print("\n📊 ESTADÍSTICAS AVANZADAS")
    print("="*50)
    print(f"💰 Total ventas (ARS): ${total_ars:,.2f}")
    print(f"📦 Cantidad de ventas: {count}")
    print(f"📈 Ticket promedio: ${total_ars/count:,.2f}" if count > 0 else "N/A")
    
    # Obtener dólar
    cotizacion = obtener_dolar_con_reintentos()
    if cotizacion:
        total_usd = convertir_a_dolares(total_ars, cotizacion)
        print(f"💵 Total ventas (USD): ${total_usd:,.2f}")
        
        # Guardar cache para futuras consultas
        guardar_cotizacion_cache(cotizacion)
    else:
        cache = cargar_cotizacion_cache()
        if cache:
            print(f"⚠️ Usando cotización cacheada del {cache['fecha']}")
            total_usd = convertir_a_dolares(total_ars, cache['cotizacion'])
            print(f"💵 Total ventas (USD aprox): ${total_usd:,.2f}")
    
    print("="*50)

def agregar_venta_interactiva():
    print("\n📝 NUEVA VENTA")
    print("-"*30)
    
    try:
        producto = input("Producto: ").strip()
        if not producto:
            print("❌ Producto requerido")
            return
        
        cantidad = int(input("Cantidad: "))
        precio = float(input("Precio unitario: "))
        
        venta = Venta(producto=producto, cantidad=cantidad, precio_unitario=precio)
        venta_id = agregar_venta(venta)
        
        print(f"\n✅ Venta #{venta_id} registrada!")
        print(f"   Total: ${venta.total():.2f}")
        
    except ValueError as e:
        print(f"❌ Error: {e}")
    except Exception as e:
        print(f"❌ Error inesperado: {e}")
        logging.error(f"Error en venta: {e}")

# ============ MAIN ============
if __name__ == "__main__":
    logging.info("=== INICIANDO GESTOR DE VENTAS ===")
    
    # Inicializar
    crear_tabla_ventas()
    
    while True:
        menu()
        opcion = input("\nSeleccione opción: ").strip()
        
        if opcion == '1':
            agregar_venta_interactiva()
        elif opcion == '2':
            ver_ventas_con_usd()
        elif opcion == '3':
            ver_ventas_con_usd()
            print("\n--- RESUMEN ---")
            estadisticas()
        elif opcion == '4':
            estadisticas()
        elif opcion == '5':
            print("\n👋 ¡Hasta luego!")
            logging.info("=== CERRANDO GESTOR ===")
            break
        else:
            print("❌ Opción inválida")
        
        input("\nPresione Enter para continuar...")
```
