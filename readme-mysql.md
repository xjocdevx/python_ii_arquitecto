### 📄 Archivo README.md
```bash 
# Ejercicios CRUD con MySQL y Python

## Requisitos previos

1. **Instalar MySQL Connector:**

pip install mysql-connector-python
```
### 2.Configurar MySQL:

 * Asegúrate de tener MySQL instalado y corriendo
 * Modifica el archivo config.py con tus credenciales


### Archivo de configuración compartido: config.py
```python
"""
config.py - Configuración central para todos los ejercicios
¡CAMBIAR ESTOS VALORES SEGÚN TU CONFIGURACIÓN DE MYSQL!
"""

DB_CONFIG = {
    'host': 'localhost',
    'user': 'root',
    'password': '123456',  # Cambia por tu contraseña
    'database': 'escuela'
}

def conectar():
    """Función auxiliar para conectar a MySQL"""
    import mysql.connector
    from mysql.connector import Error
    
    try:
        conn = mysql.connector.connect(**DB_CONFIG)
        return conn
    except Error as e:
        print(f"❌ Error de conexión: {e}")
        return None
```
### 📄 Archivo 00: 00_configuracion_inicial.py
```python
"""
EJERCICIO 0: CONFIGURACIÓN INICIAL
Ejecutar UNA SOLA VEZ antes de los demás ejercicios
"""

import mysql.connector
from mysql.connector import Error

def crear_base_datos_y_tablas():
    """Crear base de datos y tablas necesarias"""
    try:
        # Conectar sin base de datos específica
        conn = mysql.connector.connect(
            host='localhost',
            user='root',
            password='123456'  # Cambia por tu contraseña
        )
        cursor = conn.cursor()
        
        # Crear base de datos
        cursor.execute("CREATE DATABASE IF NOT EXISTS escuela")
        print("✅ Base de datos 'escuela' creada")
        
        # Usar la base de datos
        cursor.execute("USE escuela")
        
        # Crear tabla estudiantes
        cursor.execute('''
            CREATE TABLE IF NOT EXISTS estudiantes (
                id INT AUTO_INCREMENT PRIMARY KEY,
                nombre VARCHAR(100) NOT NULL,
                edad INT NOT NULL,
                grado VARCHAR(50),
                promedio DECIMAL(5,2),
                fecha_registro DATE DEFAULT (CURRENT_DATE)
            )
        ''')
        print("✅ Tabla 'estudiantes' creada")
        
        # Crear tabla cursos
        cursor.execute('''
            CREATE TABLE IF NOT EXISTS cursos (
                id INT AUTO_INCREMENT PRIMARY KEY,
                nombre_curso VARCHAR(100) NOT NULL,
                creditos INT,
                estudiante_id INT,
                FOREIGN KEY (estudiante_id) REFERENCES estudiantes(id) ON DELETE CASCADE
            )
        ''')
        print("✅ Tabla 'cursos' creada")
        
        conn.commit()
        print("\n🎉 Configuración completada exitosamente!")
        print("Ahora puedes ejecutar los ejercicios del 1 al 20.")
        
    except Error as e:
        print(f"❌ Error: {e}")
    finally:
        if 'conn' in locals() and conn.is_connected():
            cursor.close()
            conn.close()

if __name__ == "__main__":
    print("=" * 50)
    print("CONFIGURACIÓN INICIAL - CRUD MYSQL")
    print("=" * 50)
    respuesta = input("¿Ejecutar configuración? (s/n): ")
    if respuesta.lower() == 's':
        crear_base_datos_y_tablas()
    else:
        print("Configuración cancelada.")
```
### 📄 Archivo 01: 01_insertar_un_estudiante.py
```python
"""
EJERCICIO 1: INSERTAR UN ESTUDIANTE
Insertar un solo estudiante en la base de datos
"""

from config import conectar
from mysql.connector import Error

def insertar_estudiante():
    """Insertar un estudiante de ejemplo"""
    try:
        conn = conectar()
        if not conn:
            return
        
        cursor = conn.cursor()
        
        sql = "INSERT INTO estudiantes (nombre, edad, grado, promedio) VALUES (%s, %s, %s, %s)"
        valores = ("Ana García", 15, "10mo", 8.5)
        
        cursor.execute(sql, valores)
        conn.commit()
        
        print("=" * 50)
        print("RESULTADO DEL EJERCICIO 1")
        print("=" * 50)
        print(f"✅ Estudiante insertado correctamente")
        print(f"   ID asignado: {cursor.lastrowid}")
        print(f"   Nombre: {valores[0]}")
        print(f"   Edad: {valores[1]}")
        print(f"   Grado: {valores[2]}")
        print(f"   Promedio: {valores[3]}")
        
    except Error as e:
        print(f"❌ Error MySQL: {e}")
    finally:
        if conn and conn.is_connected():
            cursor.close()
            conn.close()

if __name__ == "__main__":
    insertar_estudiante()
```
### 📄 Archivo 02: 02_insertar_varios_estudiantes.py
```python
"""
EJERCICIO 2: INSERTAR MÚLTIPLES ESTUDIANTES
Insertar varios estudiantes usando executemany
"""

from config import conectar
from mysql.connector import Error

def insertar_varios_estudiantes():
    """Insertar múltiples estudiantes de una vez"""
    try:
        conn = conectar()
        if not conn:
            return
        
        cursor = conn.cursor()
        
        estudiantes = [
            ("Carlos López", 14, "9no", 7.8),
            ("María Rodríguez", 15, "10mo", 9.2),
            ("Luis Pérez", 16, "11mo", 8.0),
            ("Sofía Martínez", 14, "9no", 9.5),
            ("Juan Sánchez", 15, "10mo", 7.5)
        ]
        
        sql = "INSERT INTO estudiantes (nombre, edad, grado, promedio) VALUES (%s, %s, %s, %s)"
        cursor.executemany(sql, estudiantes)
        conn.commit()
        
        print("=" * 50)
        print("RESULTADO DEL EJERCICIO 2")
        print("=" * 50)
        print(f"✅ {cursor.rowcount} estudiantes insertados correctamente")
        print("\n📋 Lista de estudiantes insertados:")
        for i, estudiante in enumerate(estudiantes, 1):
            print(f"   {i}. {estudiante[0]}, {estudiante[1]} años, {estudiante[3]} promedio")
        
    except Error as e:
        print(f"❌ Error MySQL: {e}")
    finally:
        if conn and conn.is_connected():
            cursor.close()
            conn.close()

if __name__ == "__main__":
    insertar_varios_estudiantes()
```
### 📄 Archivo 03: 03_mostrar_todos_estudiantes.py
```python
"""
EJERCICIO 3: LEER TODOS LOS ESTUDIANTES
Mostrar todos los estudiantes registrados en la base de datos
"""

from config import conectar
from mysql.connector import Error

def mostrar_todos_estudiantes():
    """Consultar y mostrar todos los estudiantes"""
    try:
        conn = conectar()
        if not conn:
            return
        
        cursor = conn.cursor()
        
        cursor.execute("SELECT * FROM estudiantes")
        estudiantes = cursor.fetchall()
        
        print("=" * 70)
        print("RESULTADO DEL EJERCICIO 3 - LISTA DE ESTUDIANTES")
        print("=" * 70)
        print(f"{'ID':<5} {'Nombre':<25} {'Edad':<6} {'Grado':<8} {'Promedio':<10} {'Fecha Registro'}")
        print("-" * 70)
        
        for est in estudiantes:
            print(f"{est[0]:<5} {est[1]:<25} {est[2]:<6} {est[3]:<8} {est[4]:<10} {est[5]}")
        
        print("-" * 70)
        print(f"\n📊 Total de estudiantes: {len(estudiantes)}")
        
    except Error as e:
        print(f"❌ Error MySQL: {e}")
    finally:
        if conn and conn.is_connected():
            cursor.close()
            conn.close()

if __name__ == "__main__":
    mostrar_todos_estudiantes()
```
### 📄 Archivo 04: 04_buscar_por_id.py
```python
"""
EJERCICIO 4: BUSCAR ESTUDIANTE POR ID
Buscar y mostrar un estudiante específico por su ID
"""

from config import conectar
from mysql.connector import Error

def buscar_por_id(estudiante_id=1):
    """Buscar estudiante por ID"""
    try:
        conn = conectar()
        if not conn:
            return
        
        cursor = conn.cursor()
        
        cursor.execute("SELECT * FROM estudiantes WHERE id = %s", (estudiante_id,))
        estudiante = cursor.fetchone()
        
        print("=" * 50)
        print("RESULTADO DEL EJERCICIO 4 - BÚSQUEDA POR ID")
        print("=" * 50)
        
        if estudiante:
            print(f"🔍 Estudiante encontrado (ID: {estudiante_id}):")
            print(f"   Nombre: {estudiante[1]}")
            print(f"   Edad: {estudiante[2]} años")
            print(f"   Grado: {estudiante[3]}")
            print(f"   Promedio: {estudiante[4]}")
            print(f"   Registrado: {estudiante[5]}")
        else:
            print(f"❌ No se encontró estudiante con ID {estudiante_id}")
        
    except Error as e:
        print(f"❌ Error MySQL: {e}")
    finally:
        if conn and conn.is_connected():
            cursor.close()
            conn.close()

if __name__ == "__main__":
    # Puedes cambiar el ID a buscar
    buscar_por_id(1)
```
### 📄 Archivo 05: 05_actualizar_nombre.py
```python
"""
EJERCICIO 5: ACTUALIZAR NOMBRE DE ESTUDIANTE
Actualizar el nombre de un estudiante por su ID
"""

from config import conectar
from mysql.connector import Error

def actualizar_nombre(estudiante_id=1, nuevo_nombre="Ana García Fernández"):
    """Actualizar el nombre de un estudiante"""
    try:
        conn = conectar()
        if not conn:
            return
        
        cursor = conn.cursor()
        
        # Obtener nombre anterior
        cursor.execute("SELECT nombre FROM estudiantes WHERE id = %s", (estudiante_id,))
        nombre_anterior = cursor.fetchone()
        
        if not nombre_anterior:
            print(f"❌ No se encontró estudiante con ID {estudiante_id}")
            return
        
        # Actualizar nombre
        cursor.execute("UPDATE estudiantes SET nombre = %s WHERE id = %s", 
                      (nuevo_nombre, estudiante_id))
        conn.commit()
        
        print("=" * 50)
        print("RESULTADO DEL EJERCICIO 5 - ACTUALIZAR NOMBRE")
        print("=" * 50)
        print(f"✅ Nombre actualizado para ID {estudiante_id}")
        print(f"   Nombre anterior: {nombre_anterior[0]}")
        print(f"   Nuevo nombre: {nuevo_nombre}")
        
    except Error as e:
        print(f"❌ Error MySQL: {e}")
    finally:
        if conn and conn.is_connected():
            cursor.close()
            conn.close()

if __name__ == "__main__":
    actualizar_nombre()
```
### 📄 Archivo 06: 06_actualizar_promedio.py
```python
"""
EJERCICIO 6: ACTUALIZAR PROMEDIO
Actualizar el promedio de un estudiante
"""

from config import conectar
from mysql.connector import Error

def actualizar_promedio(estudiante_id=2, nuevo_promedio=9.0):
    """Actualizar el promedio de un estudiante"""
    try:
        conn = conectar()
        if not conn:
            return
        
        cursor = conn.cursor()
        
        # Obtener información del estudiante
        cursor.execute("SELECT nombre, promedio FROM estudiantes WHERE id = %s", (estudiante_id,))
        estudiante = cursor.fetchone()
        
        if not estudiante:
            print(f"❌ No se encontró estudiante con ID {estudiante_id}")
            return
        
        # Actualizar promedio
        cursor.execute("UPDATE estudiantes SET promedio = %s WHERE id = %s", 
                      (nuevo_promedio, estudiante_id))
        conn.commit()
        
        print("=" * 50)
        print("RESULTADO DEL EJERCICIO 6 - ACTUALIZAR PROMEDIO")
        print("=" * 50)
        print(f"✅ Promedio actualizado para {estudiante[0]} (ID: {estudiante_id})")
        print(f"   Promedio anterior: {estudiante[1]}")
        print(f"   Nuevo promedio: {nuevo_promedio}")
        
    except Error as e:
        print(f"❌ Error MySQL: {e}")
    finally:
        if conn and conn.is_connected():
            cursor.close()
            conn.close()

if __name__ == "__main__":
    actualizar_promedio()
```
### 📄 Archivo 07: 07_actualizar_multiple.py
```python
"""
EJERCICIO 7: ACTUALIZAR MÚLTIPLES CAMPOS
Actualizar grado y promedio de un estudiante simultáneamente
"""

from config import conectar
from mysql.connector import Error

def actualizar_multiple(estudiante_id=3, nuevo_grado="11mo", nuevo_promedio=8.8):
    """Actualizar múltiples campos de un estudiante"""
    try:
        conn = conectar()
        if not conn:
            return
        
        cursor = conn.cursor()
        
        # Obtener datos anteriores
        cursor.execute("SELECT nombre, grado, promedio FROM estudiantes WHERE id = %s", (estudiante_id,))
        estudiante = cursor.fetchone()
        
        if not estudiante:
            print(f"❌ No se encontró estudiante con ID {estudiante_id}")
            return
        
        nombre, grado_anterior, promedio_anterior = estudiante
        
        # Actualizar múltiples campos
        sql = "UPDATE estudiantes SET grado = %s, promedio = %s WHERE id = %s"
        cursor.execute(sql, (nuevo_grado, nuevo_promedio, estudiante_id))
        conn.commit()
        
        print("=" * 50)
        print("RESULTADO DEL EJERCICIO 7 - ACTUALIZAR MÚLTIPLES CAMPOS")
        print("=" * 50)
        print(f"✅ Datos actualizados para {nombre} (ID: {estudiante_id})")
        print(f"   Grado: {grado_anterior} → {nuevo_grado}")
        print(f"   Promedio: {promedio_anterior} → {nuevo_promedio}")
        
    except Error as e:
        print(f"❌ Error MySQL: {e}")
    finally:
        if conn and conn.is_connected():
            cursor.close()
            conn.close()

if __name__ == "__main__":
    actualizar_multiple()
```
### 📄 Archivo 08: 08_eliminar_estudiante.py
```python
"""
EJERCICIO 8: ELIMINAR ESTUDIANTE
Eliminar un estudiante por su ID
"""

from config import conectar
from mysql.connector import Error

def eliminar_estudiante(estudiante_id=5):
    """Eliminar un estudiante por ID"""
    try:
        conn = conectar()
        if not conn:
            return
        
        cursor = conn.cursor()
        
        # Verificar si existe el estudiante
        cursor.execute("SELECT nombre FROM estudiantes WHERE id = %s", (estudiante_id,))
        estudiante = cursor.fetchone()
        
        print("=" * 50)
        print("RESULTADO DEL EJERCICIO 8 - ELIMINAR ESTUDIANTE")
        print("=" * 50)
        
        if not estudiante:
            print(f"❌ No se encontró estudiante con ID {estudiante_id}")
            return
        
        print(f"⚠️  Estudiante a eliminar: {estudiante[0]} (ID: {estudiante_id})")
        
        # Eliminar estudiante
        cursor.execute("DELETE FROM estudiantes WHERE id = %s", (estudiante_id,))
        conn.commit()
        
        print(f"✅ Estudiante eliminado correctamente")
        
    except Error as e:
        print(f"❌ Error MySQL: {e}")
    finally:
        if conn and conn.is_connected():
            cursor.close()
            conn.close()

if __name__ == "__main__":
    eliminar_estudiante()
```
### 📄 Archivo 09: 09_filtrar_por_grado.py
```python
"""
EJERCICIO 9: FILTRAR POR GRADO
Mostrar estudiantes de un grado específico
"""

from config import conectar
from mysql.connector import Error

def filtrar_por_grado(grado_buscar="10mo"):
    """Mostrar estudiantes de un grado específico"""
    try:
        conn = conectar()
        if not conn:
            return
        
        cursor = conn.cursor()
        
        cursor.execute("SELECT nombre, edad, promedio FROM estudiantes WHERE grado = %s", (grado_buscar,))
        estudiantes = cursor.fetchall()
        
        print("=" * 50)
        print(f"RESULTADO DEL EJERCICIO 9 - ESTUDIANTES DEL GRADO {grado_buscar}")
        print("=" * 50)
        
        if estudiantes:
            for i, est in enumerate(estudiantes, 1):
                print(f"   {i}. {est[0]}, {est[1]} años, promedio: {est[2]}")
            print(f"\n📊 Total: {len(estudiantes)} estudiantes")
        else:
            print(f"   No hay estudiantes en el grado {grado_buscar}")
        
    except Error as e:
        print(f"❌ Error MySQL: {e}")
    finally:
        if conn and conn.is_connected():
            cursor.close()
            conn.close()

if __name__ == "__main__":
    filtrar_por_grado()
```
### 📄 Archivo 10: 10_filtrar_por_promedio.py
```python
"""
EJERCICIO 10: FILTRAR POR PROMEDIO
Mostrar estudiantes con promedio mayor a un valor específico
"""

from config import conectar
from mysql.connector import Error

def filtrar_por_promedio(promedio_minimo=8.5):
    """Mostrar estudiantes con promedio mayor al mínimo"""
    try:
        conn = conectar()
        if not conn:
            return
        
        cursor = conn.cursor()
        
        cursor.execute("""
            SELECT nombre, promedio, grado 
            FROM estudiantes 
            WHERE promedio > %s 
            ORDER BY promedio DESC
        """, (promedio_minimo,))
        
        estudiantes = cursor.fetchall()
        
        print("=" * 50)
        print(f"RESULTADO DEL EJERCICIO 10 - PROMEDIO > {promedio_minimo}")
        print("=" * 50)
        
        if estudiantes:
            print(f"🌟 Estudiantes destacados:")
            for i, est in enumerate(estudiantes, 1):
                print(f"   {i}. {est[0]}: {est[1]} - {est[2]}")
            print(f"\n📊 Total: {len(estudiantes)} estudiantes")
        else:
            print(f"   No hay estudiantes con promedio mayor a {promedio_minimo}")
        
    except Error as e:
        print(f"❌ Error MySQL: {e}")
    finally:
        if conn and conn.is_connected():
            cursor.close()
            conn.close()

if __name__ == "__main__":
    filtrar_por_promedio()
```
### 📄 Archivo 11: 11_ordenar_por_edad.py
```python
"""
EJERCICIO 11: ORDENAR POR EDAD
Mostrar estudiantes ordenados por edad (menor a mayor)
"""

from config import conectar
from mysql.connector import Error

def ordenar_por_edad():
    """Mostrar estudiantes ordenados por edad ascendente"""
    try:
        conn = conectar()
        if not conn:
            return
        
        cursor = conn.cursor()
        
        cursor.execute("SELECT nombre, edad, grado, promedio FROM estudiantes ORDER BY edad ASC")
        estudiantes = cursor.fetchall()
        
        print("=" * 60)
        print("RESULTADO DEL EJERCICIO 11 - ESTUDIANTES ORDENADOS POR EDAD")
        print("=" * 60)
        print(f"{'Nombre':<25} {'Edad':<6} {'Grado':<8} {'Promedio':<10}")
        print("-" * 60)
        
        for est in estudiantes:
            print(f"{est[0]:<25} {est[1]:<6} {est[2]:<8} {est[3]:<10}")
        
        print("-" * 60)
        print(f"📊 Total: {len(estudiantes)} estudiantes")
        
    except Error as e:
        print(f"❌ Error MySQL: {e}")
    finally:
        if conn and conn.is_connected():
            cursor.close()
            conn.close()

if __name__ == "__main__":
    ordenar_por_edad()
```
### 📄 Archivo 12: 12_contar_estudiantes.py
```python
"""
EJERCICIO 12: CONTAR ESTUDIANTES
Contar el número total de estudiantes y distribución por grado
"""

from config import conectar
from mysql.connector import Error

def contar_estudiantes():
    """Mostrar estadísticas de cantidad de estudiantes"""
    try:
        conn = conectar()
        if not conn:
            return
        
        cursor = conn.cursor()
        
        # Total de estudiantes
        cursor.execute("SELECT COUNT(*) as total FROM estudiantes")
        total = cursor.fetchone()[0]
        
        # Distribución por grado
        cursor.execute("SELECT grado, COUNT(*) as cantidad FROM estudiantes GROUP BY grado")
        por_grado = cursor.fetchall()
        
        print("=" * 50)
        print("RESULTADO DEL EJERCICIO 12 - ESTADÍSTICAS")
        print("=" * 50)
        print(f"📊 Total de estudiantes: {total}")
        
        if por_grado:
            print("\n📚 Distribución por grado:")
            for grado, cantidad in por_grado:
                porcentaje = (cantidad / total) * 100 if total > 0 else 0
                print(f"   • {grado}: {cantidad} estudiantes ({porcentaje:.1f}%)")
        
    except Error as e:
        print(f"❌ Error MySQL: {e}")
    finally:
        if conn and conn.is_connected():
            cursor.close()
            conn.close()

if __name__ == "__main__":
    contar_estudiantes()
```
### 📄 Archivo 13: 13_promedio_general.py
```python
"""
EJERCICIO 13: PROMEDIO GENERAL
Calcular el promedio general, máximo y mínimo de todos los estudiantes
"""

from config import conectar
from mysql.connector import Error

def promedio_general():
    """Calcular estadísticas de promedios"""
    try:
        conn = conectar()
        if not conn:
            return
        
        cursor = conn.cursor()
        
        # Promedio general
        cursor.execute("SELECT AVG(promedio) as promedio_general FROM estudiantes")
        promedio = cursor.fetchone()[0]
        
        # Máximo y mínimo
        cursor.execute("SELECT MAX(promedio) as maximo, MIN(promedio) as minimo FROM estudiantes")
        max_min = cursor.fetchone()
        
        print("=" * 50)
        print("RESULTADO DEL EJERCICIO 13 - ESTADÍSTICAS DE CALIFICACIONES")
        print("=" * 50)
        print(f"📈 Promedio general: {promedio:.2f}" if promedio else "📈 Promedio general: N/A")
        print(f"🏆 Promedio más alto: {max_min[0]:.2f}" if max_min[0] else "🏆 Promedio más alto: N/A")
        print(f"📉 Promedio más bajo: {max_min[1]:.2f}" if max_min[1] else "📉 Promedio más bajo: N/A")
        
        # Estudiantes con promedio arriba/abajo del promedio
        if promedio:
            cursor.execute("SELECT nombre, promedio FROM estudiantes WHERE promedio > %s", (promedio,))
            arriba = cursor.fetchall()
            print(f"\n🌟 Estudiantes sobre el promedio: {len(arriba)}")
            
            cursor.execute("SELECT nombre, promedio FROM estudiantes WHERE promedio < %s", (promedio,))
            abajo = cursor.fetchall()
            print(f"📚 Estudiantes bajo el promedio: {len(abajo)}")
        
    except Error as e:
        print(f"❌ Error MySQL: {e}")
    finally:
        if conn and conn.is_connected():
            cursor.close()
            conn.close()

if __name__ == "__main__":
    promedio_general()
```
### 📄 Archivo 14: 14_buscar_por_nombre_like.py
```python
"""
EJERCICIO 14: BUSCAR POR NOMBRE (LIKE)
Buscar estudiantes por coincidencia parcial en el nombre
"""

from config import conectar
from mysql.connector import Error

def buscar_por_nombre(termino="a"):
    """Buscar estudiantes cuyo nombre contenga el término"""
    try:
        conn = conectar()
        if not conn:
            return
        
        cursor = conn.cursor()
        
        # LIKE con comodín % para búsqueda parcial
        cursor.execute("SELECT id, nombre, grado, promedio FROM estudiantes WHERE nombre LIKE %s", 
                      (f'%{termino}%',))
        estudiantes = cursor.fetchall()
        
        print("=" * 60)
        print(f"RESULTADO DEL EJERCICIO 14 - BÚSQUEDA POR NOMBRE")
        print("=" * 60)
        print(f"🔍 Término buscado: '{termino}'")
        print("-" * 60)
        
        if estudiantes:
            print(f"{'ID':<5} {'Nombre':<25} {'Grado':<8} {'Promedio':<10}")
            print("-" * 60)
            for est in estudiantes:
                print(f"{est[0]:<5} {est[1]:<25} {est[2]:<8} {est[3]:<10}")
            print("-" * 60)
            print(f"\n📊 Encontrados: {len(estudiantes)} estudiantes")
        else:
            print(f"   No se encontraron estudiantes con '{termino}' en el nombre")
        
    except Error as e:
        print(f"❌ Error MySQL: {e}")
    finally:
        if conn and conn.is_connected():
            cursor.close()
            conn.close()

if __name__ == "__main__":
    # Puedes cambiar el término de búsqueda
    buscar_por_nombre("a")
```
### 📄 Archivo 15: 15_limit_resultados.py
```python
"""
EJERCICIO 15: LIMITAR RESULTADOS
Mostrar solo los primeros N estudiantes usando LIMIT
"""

from config import conectar
from mysql.connector import Error

def limitar_resultados(limite=3):
    """Mostrar solo los primeros 'limite' estudiantes"""
    try:
        conn = conectar()
        if not conn:
            return
        
        cursor = conn.cursor()
        
        cursor.execute("SELECT nombre, edad, grado, promedio FROM estudiantes LIMIT %s", (limite,))
        estudiantes = cursor.fetchall()
        
        print("=" * 60)
        print(f"RESULTADO DEL EJERCICIO 15 - LIMITAR A {limite} ESTUDIANTES")
        print("=" * 60)
        
        if estudiantes:
            print(f"{'#':<3} {'Nombre':<25} {'Edad':<6} {'Grado':<8} {'Promedio':<10}")
            print("-" * 60)
            for i, est in enumerate(estudiantes, 1):
                print(f"{i:<3} {est[0]:<25} {est[1]:<6} {est[2]:<8} {est[3]:<10}")
        else:
            print("   No hay estudiantes registrados")
        
        # Mostrar total disponible
        cursor.execute("SELECT COUNT(*) FROM estudiantes")
        total = cursor.fetchone()[0]
        print("-" * 60)
        print(f"📊 Mostrando {len(estudiantes)} de {total} estudiantes")
        
    except Error as e:
        print(f"❌ Error MySQL: {e}")
    finally:
        if conn and conn.is_connected():
            cursor.close()
            conn.close()

if __name__ == "__main__":
    limitar_resultados()
```
### 📄 Archivo 16: 16_paginacion.py
```python
"""
EJERCICIO 16: PAGINACIÓN
Implementar paginación para mostrar estudiantes página por página
"""

from config import conectar
from mysql.connector import Error

def paginacion(pagina=1, por_pagina=2):
    """Mostrar estudiantes con paginación"""
    try:
        conn = conectar()
        if not conn:
            return
        
        cursor = conn.cursor()
        
        # Calcular offset
        offset = (pagina - 1) * por_pagina
        
        # Obtener estudiantes de la página actual
        cursor.execute("SELECT nombre, grado, promedio FROM estudiantes LIMIT %s OFFSET %s", 
                      (por_pagina, offset))
        estudiantes = cursor.fetchall()
        
        # Obtener total de estudiantes
        cursor.execute("SELECT COUNT(*) FROM estudiantes")
        total = cursor.fetchone()[0]
        total_paginas = (total + por_pagina - 1) // por_pagina if total > 0 else 1
        
        print("=" * 60)
        print(f"RESULTADO DEL EJERCICIO 16 - PAGINACIÓN")
        print("=" * 60)
        print(f"📄 Página {pagina} de {total_paginas} (Mostrando {por_pagina} por página)")
        print("-" * 60)
        
        if estudiantes:
            for i, est in enumerate(estudiantes, 1):
                print(f"   {i + offset}. {est[0]} - {est[1]} - Promedio: {est[2]}")
        else:
            print("   No hay estudiantes en esta página")
        
        print("-" * 60)
        print(f"📊 Total de estudiantes: {total}")
        print(f"📑 Total de páginas: {total_paginas}")
        
    except Error as e:
        print(f"❌ Error MySQL: {e}")
    finally:
        if conn and conn.is_connected():
            cursor.close()
            conn.close()

if __name__ == "__main__":
    paginacion(pagina=1, por_pagina=2)
```
### 📄 Archivo 17: 17_crear_cursos.py
```python
"""
EJERCICIO 17: CREAR CURSOS RELACIONADOS
Insertar cursos relacionados con estudiantes (relación 1:N)
"""

from config import conectar
from mysql.connector import Error

def crear_cursos():
    """Insertar cursos para diferentes estudiantes"""
    try:
        conn = conectar()
        if not conn:
            return
        
        cursor = conn.cursor()
        
        # Verificar que existan estudiantes
        cursor.execute("SELECT id, nombre FROM estudiantes")
        estudiantes = cursor.fetchall()
        
        if not estudiantes:
            print("❌ No hay estudiantes registrados. Ejecuta primero los ejercicios 1-2.")
            return
        
        # Insertar cursos relacionados
        cursos = [
            ("Matemáticas", 4, estudiantes[0][0]),
            ("Física", 3, estudiantes[0][0]),
            ("Literatura", 3, estudiantes[1][0] if len(estudiantes) > 1 else estudiantes[0][0]),
            ("Historia", 2, estudiantes[2][0] if len(estudiantes) > 2 else estudiantes[0][0]),
            ("Programación", 4, estudiantes[3][0] if len(estudiantes) > 3 else estudiantes[0][0])
        ]
        
        sql = "INSERT INTO cursos (nombre_curso, creditos, estudiante_id) VALUES (%s, %s, %s)"
        cursor.executemany(sql, cursos)
        conn.commit()
        
        print("=" * 60)
        print("RESULTADO DEL EJERCICIO 17 - CREAR CURSOS")
        print("=" * 60)
        print(f"✅ {cursor.rowcount} cursos insertados")
        print("\n📚 Cursos registrados:")
        
        for curso in cursos:
            # Buscar nombre del estudiante
            for est in estudiantes:
                if est[0] == curso[2]:
                    print(f"   • {curso[0]} ({curso[1]} créditos) - Estudiante: {est[1]}")
                    break
        
    except Error as e:
        print(f"❌ Error MySQL: {e}")
    finally:
        if conn and conn.is_connected():
            cursor.close()
            conn.close()

if __name__ == "__main__":
    crear_cursos()
```
### 📄 Archivo 18: 18_join_tablas.py
```python
"""
EJERCICIO 18: JOIN ENTRE TABLAS
Mostrar estudiantes con sus cursos usando LEFT JOIN
"""

from config import conectar
from mysql.connector import Error

def join_tablas():
    """Mostrar estudiantes y sus cursos usando JOIN"""
    try:
        conn = conectar()
        if not conn:
            return
        
        cursor = conn.cursor()
        
        query = '''
        SELECT e.id, e.nombre, e.grado, c.nombre_curso, c.creditos
        FROM estudiantes e
        LEFT JOIN cursos c ON e.id = c.estudiante_id
        ORDER BY e.nombre, c.nombre_curso
        '''
        
        cursor.execute(query)
        resultados = cursor.fetchall()
        
        print("=" * 70)
        print("RESULTADO DEL EJERCICIO 18 - JOIN (ESTUDIANTES Y CURSOS)")
        print("=" * 70)
        
        estudiante_actual = None
        for id_est, nombre, grado, curso, creditos in resultados:
            if nombre != estudiante_actual:
                if estudiante_actual:
                    print()
                print(f"\n📌 {nombre} (ID: {id_est}) - {grado}:")
                estudiante_actual = nombre
            
            if curso:
                print(f"      → {curso} ({creditos} créditos)")
            else:
                print(f"      → Sin cursos asignados")
        
        if not resultados:
            print("   No hay datos disponibles")
        
    except Error as e:
        print(f"❌ Error MySQL: {e}")
    finally:
        if conn and conn.is_connected():
            cursor.close()
            conn.close()

if __name__ == "__main__":
    join_tablas()
```
### 📄 Archivo 19: 19_contar_cursos_por_estudiante.py
```python
"""
EJERCICIO 19: CONTAR CURSOS POR ESTUDIANTE
Usar GROUP BY para contar cuántos cursos tiene cada estudiante
"""

from config import conectar
from mysql.connector import Error

def contar_cursos_por_estudiante():
    """Mostrar cantidad de cursos por estudiante"""
    try:
        conn = conectar()
        if not conn:
            return
        
        cursor = conn.cursor()
        
        query = '''
        SELECT e.nombre, e.grado, COUNT(c.id) as total_cursos
        FROM estudiantes e
        LEFT JOIN cursos c ON e.id = c.estudiante_id
        GROUP BY e.id
        ORDER BY total_cursos DESC
        '''
        
        cursor.execute(query)
        resultados = cursor.fetchall()
        
        print("=" * 60)
        print("RESULTADO DEL EJERCICIO 19 - CURSOS POR ESTUDIANTE")
        print("=" * 60)
        print(f"{'Estudiante':<25} {'Grado':<8} {'Cursos':<10}")
        print("-" * 60)
        
        total_cursos = 0
        for nombre, grado, total in resultados:
            print(f"{nombre:<25} {grado:<8} {total:<10}")
            total_cursos += total
        
        print("-" * 60)
        print(f"\n📊 Total de estudiantes: {len(resultados)}")
        print(f"📚 Total de cursos registrados: {total_cursos}")
        
        # Promedio de cursos por estudiante
        if len(resultados) > 0:
            promedio = total_cursos / len(resultados)
            print(f"📈 Promedio de cursos por estudiante: {promedio:.1f}")
        
    except Error as e:
        print(f"❌ Error MySQL: {e}")
    finally:
        if conn and conn.is_connected():
            cursor.close()
            conn.close()

if __name__ == "__main__":
    contar_cursos_por_estudiante()
```
### 📄 Archivo 20: 20_menu_crud_completo.py
```python
"""
EJERCICIO 20: CRUD COMPLETO CON MENÚ
Sistema completo con menú interactivo para todas las operaciones CRUD
"""

from config import conectar
from mysql.connector import Error

def crear_estudiante():
    """Crear un nuevo estudiante"""
    print("\n--- CREAR NUEVO ESTUDIANTE ---")
    nombre = input("Nombre: ")
    edad = int(input("Edad: "))
    grado = input("Grado: ")
    promedio = float(input("Promedio: "))
    
    try:
        conn = conectar()
        if not conn:
            return
        
        cursor = conn.cursor()
        cursor.execute("INSERT INTO estudiantes (nombre, edad, grado, promedio) VALUES (%s, %s, %s, %s)",
                      (nombre, edad, grado, promedio))
        conn.commit()
        
        print(f"✅ Estudiante creado con ID {cursor.lastrowid}")
        cursor.close()
        conn.close()
    except Error as e:
        print(f"❌ Error: {e}")

def leer_estudiantes():
    """Mostrar todos los estudiantes"""
    try:
        conn = conectar()
        if not conn:
            return
        
        cursor = conn.cursor()
        cursor.execute("SELECT id, nombre, edad, grado, promedio FROM estudiantes")
        estudiantes = cursor.fetchall()
        
        print("\n" + "=" * 70)
        print("📚 LISTA DE ESTUDIANTES")
        print("=" * 70)
        print(f"{'ID':<5} {'Nombre':<25} {'Edad':<6} {'Grado':<8} {'Promedio':<10}")
        print("-" * 70)
        
        for est in estudiantes:
            print(f"{est[0]:<5} {est[1]:<25} {est[2]:<6} {est[3]:<8} {est[4]:<10}")
        
        print("-" * 70)
        print(f"Total: {len(estudiantes)} estudiantes")
        
        cursor.close()
        conn.close()
    except Error as e:
        print(f"❌ Error: {e}")

def actualizar_estudiante():
    """Actualizar datos de un estudiante"""
    try:
        estudiante_id = int(input("ID del estudiante a actualizar: "))
        
        conn = conectar()
        if not conn:
            return
        
        cursor = conn.cursor()
        
        # Verificar si existe
        cursor.execute("SELECT nombre FROM estudiantes WHERE id = %s", (estudiante_id,))
        if not cursor.fetchone():
            print(f"❌ No se encontró estudiante con ID {estudiante_id}")
            cursor.close()
            conn.close()
            return
        
        print("\n--- ACTUALIZAR DATOS (dejar en blanco para no cambiar) ---")
        nuevo_nombre = input("Nuevo nombre: ")
        nuevo_grado = input("Nuevo grado: ")
        nuevo_promedio = input("Nuevo promedio: ")
        
        if nuevo_nombre:
            cursor.execute("UPDATE estudiantes SET nombre = %s WHERE id = %s", (nuevo_nombre, estudiante_id))
        if nuevo_grado:
            cursor.execute("UPDATE estudiantes SET grado = %s WHERE id = %s", (nuevo_grado, estudiante_id))
        if nuevo_promedio:
            cursor.execute("UPDATE estudiantes SET promedio = %s WHERE id = %s", (float(nuevo_promedio), estudiante_id))
        
        conn.commit()
        print(f"✅ Estudiante ID {estudiante_id} actualizado")
        
        cursor.close()
        conn.close()
    except ValueError:
        print("❌ Error: ID o promedio inválido")
    except Error as e:
        print(f"❌ Error MySQL: {e}")

def eliminar_estudiante():
    """Eliminar un estudiante"""
    try:
        estudiante_id = int(input("ID del estudiante a eliminar: "))
        
        conn = conectar()
        if not conn:
            return
        
        cursor = conn.cursor()
        
        # Verificar si existe
        cursor.execute("SELECT nombre FROM estudiantes WHERE id = %s", (estudiante_id,))
        estudiante = cursor.fetchone()
        
        if not estudiante:
            print(f"❌ No se encontró estudiante con ID {estudiante_id}")
            cursor.close()
            conn.close()
            return
        
        confirmar = input(f"¿Eliminar a {estudiante[0]}? (s/n): ")
        if confirmar.lower() == 's':
            cursor.execute("DELETE FROM estudiantes WHERE id = %s", (estudiante_id,))
            conn.commit()
            print(f"✅ Estudiante ID {estudiante_id} eliminado")
        else:
            print("Eliminación cancelada")
        
        cursor.close()
        conn.close()
    except ValueError:
        print("❌ Error: ID inválido")
    except Error as e:
        print(f"❌ Error MySQL: {e}")

def menu_principal():
    """Menú principal del sistema CRUD"""
    while True:
        print("\n" + "=" * 50)
        print("🔄 SISTEMA CRUD - MENÚ COMPLETO")
        print("=" * 50)
        print("1. Crear estudiante (CREATE)")
        print("2. Leer estudiantes (READ)")
        print("3. Actualizar estudiante (UPDATE)")
        print("4. Eliminar estudiante (DELETE)")
        print("5. Salir")
        print("=" * 50)
        
        opcion = input("Seleccione una opción (1-5): ")
        
        if opcion == '1':
            crear_estudiante()
        elif opcion == '2':
            leer_estudiantes()
        elif opcion == '3':
            actualizar_estudiante()
        elif opcion == '4':
            eliminar_estudiante()
        elif opcion == '5':
            print("\n👋 ¡Hasta luego!")
            break
        else:
            print("❌ Opción inválida. Intente nuevamente.")

if __name__ == "__main__":
    print("=" * 50)
    print("🎓 SISTEMA CRUD - GESTIÓN DE ESTUDIANTES")
    print("=" * 50)
    menu_principal()
```
