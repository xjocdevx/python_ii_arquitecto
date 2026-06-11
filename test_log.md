### LOGS
```python
import logging

logging.basicConfig(level=logging.DEBUG)

def function_whitch_logs(x: int, y: int) -> float:
    """ Divide x por y!"""
    try:
        result=x/y
    except ZeroDivisionError:
            logging.error("Se detecto una division por cero", exc_info=False )
            return 0
    else:
        logging.info(f"retorna x={x} dividiendo con y={y}")
        return result

# print(function_whitch_logs(120, 2))
print(function_whitch_logs(120, 0))
```    

### 001_ejercicio_logs_archivo.py
```python
"""
Ejercicio 14: Logs profesionales con archivos .log
Objetivo: Implementar logging sistemático en aplicaciones Python

Sentencias esenciales:
- logging.basicConfig(): Configuración básica de logging
- logging.info(), .error(), .warning(): Niveles de log
- Formato personalizado con timestamp y nivel

Niveles de logging (de menor a mayor severidad):
DEBUG    → Información detallada para debugging
INFO     → Confirmación de que todo funciona
WARNING  → Algo inesperado, pero el programa continúa
ERROR    → Problema más serio, función falló
CRITICAL → Error grave, programa puede abortar
"""

import logging
import os
from datetime import datetime

# ============================================
# CONFIGURACIÓN DE LOGGING
# ============================================

def configurar_logging():
    """
    Configura el sistema de logging con formato profesional
    
    Parámetros de basicConfig:
    - filename: Archivo donde guardar los logs
    - level: Nivel mínimo a registrar
    - format: Formato de cada línea de log
    - datefmt: Formato de la fecha/hora
    - encoding: Codificación del archivo
    """
    
    # Crear directorio para logs si no existe
    os.makedirs('logs', exist_ok=True)
    
    # Configuración básica
    logging.basicConfig(
        filename='logs/aplicacion.log',
        level=logging.DEBUG,  # Capturar todos los niveles
        format='%(asctime)s | %(levelname)-8s | %(name)-12s | %(funcName)-15s | %(message)s',
        datefmt='%Y-%m-%d %H:%M:%S',
        encoding='utf-8'
    )
    
    # También mostrar logs en consola (opcional)
    console_handler = logging.StreamHandler()
    console_handler.setLevel(logging.INFO)
    console_format = logging.Formatter('%(levelname)s: %(message)s')
    console_handler.setFormatter(console_format)
    logging.getLogger().addHandler(console_handler)


def obtener_logger(nombre_modulo):
    """
    Obtiene un logger específico para un módulo
    
    Args:
        nombre_modulo: Nombre del módulo/clase que usa el logger
    
    Returns:
        logging.Logger: Logger configurado
    """
    return logging.getLogger(nombre_modulo)


# ============================================
# CLASE DE EJEMPLO CON LOGGING
# ============================================

class ProcesadorTransacciones:
    """Simula un procesador de transacciones bancarias con logging"""
    
    def __init__(self, nombre_usuario):
        self.logger = obtener_logger(f"Transacciones.{nombre_usuario}")
        self.nombre_usuario = nombre_usuario
        self.saldo = 0.0
        self.logger.info(f"Inicializando cuenta para usuario '{nombre_usuario}'")
    
    def depositar(self, cantidad):
        """Realiza un depósito en la cuenta"""
        self.logger.debug(f"Intentando depósito de ${cantidad:.2f}")
        
        if cantidad <= 0:
            self.logger.warning(f"Intento de depósito inválido: ${cantidad:.2f}")
            return False
        
        self.saldo += cantidad
        self.logger.info(f"Depósito exitoso: +${cantidad:.2f}. Nuevo saldo: ${self.saldo:.2f}")
        return True
    
    def retirar(self, cantidad):
        """Realiza un retiro de la cuenta"""
        self.logger.debug(f"Intentando retiro de ${cantidad:.2f}")
        
        if cantidad <= 0:
            self.logger.warning(f"Intento de retiro inválido: ${cantidad:.2f}")
            return False
        
        if cantidad > self.saldo:
            self.logger.error(f"Fondos insuficientes. Saldo: ${self.saldo:.2f}, Retiro: ${cantidad:.2f}")
            return False
        
        self.saldo -= cantidad
        self.logger.info(f"Retiro exitoso: -${cantidad:.2f}. Nuevo saldo: ${self.saldo:.2f}")
        return True
    
    def consultar_saldo(self):
        """Consulta el saldo actual"""
        self.logger.info(f"Consulta de saldo: ${self.saldo:.2f}")
        return self.saldo


class CalculadoraCientifica:
    """Calculadora con logging de operaciones"""
    
    def __init__(self):
        self.logger = obtener_logger("Calculadora")
        self.operaciones_realizadas = 0
        self.logger.info("Calculadora científica inicializada")
    
    def dividir(self, a, b):
        """División con manejo de errores y logging"""
        self.logger.debug(f"Operación división: {a} / {b}")
        self.operaciones_realizadas += 1
        
        try:
            if b == 0:
                self.logger.error(f"División por cero intentada: {a} / {b}")
                raise ZeroDivisionError("No se puede dividir por cero")
            
            resultado = a / b
            self.logger.info(f"División exitosa: {a} / {b} = {resultado}")
            return resultado
            
        except Exception as e:
            self.logger.exception(f"Error en división: {str(e)}")
            raise
    
    def raiz_cuadrada(self, numero):
        """Calcula raíz cuadrada con logging"""
        self.logger.debug(f"Calculando raíz cuadrada de {numero}")
        self.operaciones_realizadas += 1
        
        if numero < 0:
            self.logger.error(f"Raíz cuadrada de número negativo: {numero}")
            raise ValueError("No se puede calcular raíz cuadrada de número negativo")
        
        import math
        resultado = math.sqrt(numero)
        self.logger.info(f"Raíz cuadrada: √{numero} = {resultado}")
        return resultado


# ============================================
# FUNCIÓN PRINCIPAL DE DEMOSTRACIÓN
# ============================================

def demostrar_logging():
    """Demuestra el uso de logging en diferentes niveles"""
    
    print("="*50)
    print("EJERCICIO 14: LOGS PROFESIONALES")
    print("="*50)
    
    # 1. Configurar logging
    configurar_logging()
    logger_principal = obtener_logger("Main")
    
    logger_principal.info("="*50)
    logger_principal.info("INICIANDO DEMOSTRACIÓN DE LOGGING")
    logger_principal.info("="*50)
    
    # 2. Demostrar diferentes niveles de log
    print("\n📝 Generando logs de diferentes niveles...")
    
    logger_principal.debug("Este es un mensaje DEBUG (solo en archivo)")
    logger_principal.info("Este es un mensaje INFO")
    logger_principal.warning("Este es un mensaje WARNING - algo inusual")
    logger_principal.error("Este es un mensaje ERROR - algo falló")
    logger_principal.critical("Este es un mensaje CRITICAL - error grave")
    
    # 3. Usar la clase de transacciones
    print("\n💳 Probando ProcesadorTransacciones...")
    transacciones = ProcesadorTransacciones("usuario123")
    transacciones.depositar(1000)
    transacciones.retirar(500)
    transacciones.retirar(600)  # Esto causará un error
    transacciones.depositar(-50)  # Depósito inválido
    saldo_final = transacciones.consultar_saldo()
    
    # 4. Usar la calculadora
    print("\n🧮 Probando CalculadoraCientifica...")
    calc = CalculadoraCientifica()
    
    try:
        calc.dividir(10, 2)
        calc.dividir(10, 0)  # Esto causará error
    except ZeroDivisionError:
        pass
    
    calc.raiz_cuadrada(16)
    
    try:
        calc.raiz_cuadrada(-4)  # Esto causará error
    except ValueError:
        pass
    
    # 5. Mostrar estadísticas
    logger_principal.info(f"Total operaciones calculadora: {calc.operaciones_realizadas}")
    
    logger_principal.info("DEMOSTRACIÓN DE LOGGING FINALIZADA")
    
    print("\n✅ Demostración completada")
    print(f"📁 Revisa el archivo 'logs/aplicacion.log' para ver los logs generados")
    print(f"📊 Tamaño del archivo de log: {os.path.getsize('logs/aplicacion.log')} bytes")


def analizar_archivo_log():
    """Función para leer y analizar el archivo de log"""
    
    log_file = 'logs/aplicacion.log'
    
    if not os.path.exists(log_file):
        print("No se encontró archivo de log")
        return
    
    print("\n" + "="*50)
    print("ANÁLISIS DEL ARCHIVO DE LOG")
    print("="*50)
    
    with open(log_file, 'r', encoding='utf-8') as f:
        lineas = f.readlines()
    
    # Contar por nivel
    niveles = {
        'DEBUG': 0,
        'INFO': 0,
        'WARNING': 0,
        'ERROR': 0,
        'CRITICAL': 0
    }
    
    for linea in lineas:
        for nivel in niveles:
            if f'| {nivel} |' in linea or f'| {nivel:<8} |' in linea:
                niveles[nivel] += 1
                break
    
    print("\n📊 Estadísticas de logs:")
    for nivel, count in niveles.items():
        if count > 0:
            print(f"  • {nivel}: {count} mensajes")
    
    print(f"\n📄 Total de líneas: {len(lineas)}")
    print(f"📁 Ubicación: {os.path.abspath(log_file)}")
    
    # Mostrar últimos 5 logs
    print("\n🔍 Últimos 5 mensajes:")
    for linea in lineas[-5:]:
        print(f"  {linea.strip()}")


if __name__ == "__main__":
    demostrar_logging()
    analizar_archivo_log()
    
    print("\n" + "="*50)
    print("📚 BUENAS PRÁCTICAS DE LOGGING:")
    print("="*50)
    print("""
    1. USAR NIVELES APROPIADOS:
       - DEBUG: Información detallada (solo en desarrollo)
       - INFO: Eventos normales del programa
       - WARNING: Problemas potenciales
       - ERROR: Fallos recuperables
       - CRITICAL: Fallos graves
    
    2. FORMATO CONSISTENTE:
       - Incluir timestamp, nivel, módulo, mensaje
       - Usar formato estructurado para fácil parsing
    
    3. NO LOGGEAR INFORMACIÓN SENSIBLE:
       - Contraseñas, tokens, datos personales
       - Usar placeholders o enmascaramiento
    
    4. ROTACIÓN DE LOGS:
       - Usar RotatingFileHandler para archivos grandes
       - Configurar tamaño máximo y backups
    
    5. CONTEXTO ÚTIL:
       - Incluir IDs de transacción
       - Tiempos de ejecución
       - Parámetros relevantes
    
    6. MANEJO DE EXCEPCIONES:
       - Usar logger.exception() dentro de except
       - Incluye automáticamente el traceback
    """)
```
### 002_ejercicio_logs_archivo.py
```python
"""
Ejercicio 15: Rotación de logs
Objetivo: Implementar rotación automática de archivos de log

Sentencias esenciales:
- RotatingFileHandler: Rota archivos cuando alcanzan tamaño límite
- TimedRotatingFileHandler: Rota basado en tiempo
- maxBytes: Tamaño máximo antes de rotar
- backupCount: Número de archivos de backup a mantener

¿Por qué rotar logs?
- Evitar que los archivos crezcan indefinidamente
- Facilitar la gestión y análisis
- Ahorrar espacio en disco
- Mantener rendimiento del sistema
"""

import logging
import time
import os
from logging.handlers import RotatingFileHandler, TimedRotatingFileHandler
import random

class LogRotator:
    """Gestor de logs con rotación automática"""
    
    def __init__(self, nombre_archivo, tamano_maximo_mb=1, backups=3):
        """
        Configura el sistema de logs con rotación por tamaño
        
        Args:
            nombre_archivo: Nombre base del archivo de log
            tamano_maximo_mb: Tamaño máximo en MB antes de rotar
            backups: Número de archivos de backup a mantener
        """
        # Calcular bytes desde MB
        tamano_maximo_bytes = tamano_maximo_mb * 1024 * 1024
        
        # Crear directorio si no existe
        os.makedirs('logs', exist_ok=True)
        
        # Configurar el handler con rotación por tamaño
        self.handler = RotatingFileHandler(
            filename=f'logs/{nombre_archivo}.log',
            maxBytes=tamano_maximo_bytes,
            backupCount=backups,
            encoding='utf-8'
        )
        
        # Configurar formato
        formatter = logging.Formatter(
            '%(asctime)s | %(levelname)s | %(funcName)s | %(message)s',
            datefmt='%H:%M:%S'
        )
        self.handler.setFormatter(formatter)
        
        # Crear logger
        self.logger = logging.getLogger(f'Rotador.{nombre_archivo}')
        self.logger.setLevel(logging.DEBUG)
        
        # Evitar duplicar handlers si ya existe
        if not self.logger.handlers:
            self.logger.addHandler(self.handler)
        
        self.nombre_base = nombre_archivo
        self.archivo_actual = f'logs/{nombre_archivo}.log'
    
    def escribir_mensaje(self, nivel, mensaje):
        """Escribe un mensaje en el log con el nivel especificado"""
        if nivel == 'debug':
            self.logger.debug(mensaje)
        elif nivel == 'info':
            self.logger.info(mensaje)
        elif nivel == 'warning':
            self.logger.warning(mensaje)
        elif nivel == 'error':
            self.logger.error(mensaje)
    
    def obtener_archivos_log(self):
        """Obtiene lista de todos los archivos de log relacionados"""
        archivos = []
        for archivo in os.listdir('logs'):
            if archivo.startswith(self.nombre_base) and archivo.endswith('.log'):
                archivos.append(archivo)
        return sorted(archivos)
    
    def mostrar_estado_logs(self):
        """Muestra el estado actual de todos los archivos de log"""
        archivos = self.obtener_archivos_log()
        
        print(f"\n📁 Archivos de log para '{self.nombre_base}':")
        for archivo in archivos:
            ruta = os.path.join('logs', archivo)
            tamaño = os.path.getsize(ruta)
            print(f"  • {archivo}: {tamaño} bytes ({tamaño/1024:.2f} KB)")


class RotacionPorTiempo:
    """Logs que rotan basados en tiempo (cada X segundos)"""
    
    def __init__(self, nombre_archivo, intervalo_segundos=10, backups=3):
        """
        Configura rotación por tiempo
        
        Args:
            nombre_archivo: Nombre base del archivo
            intervalo_segundos: Cada cuántos segundos rotar
            backups: Número de backups a mantener
        """
        os.makedirs('logs', exist_ok=True)
        
        # TimedRotatingFileHandler rota basado en tiempo
        # 'S' = segundos, 'M' = minutos, 'H' = horas, 'D' = días
        self.handler = TimedRotatingFileHandler(
            filename=f'logs/{nombre_archivo}_tiempo.log',
            when='S',  # Rotar cada S segundos
            interval=intervalo_segundos,
            backupCount=backups,
            encoding='utf-8'
        )
        
        formatter = logging.Formatter('%(asctime)s - %(message)s')
        self.handler.setFormatter(formatter)
        
        self.logger = logging.getLogger(f'TiempoRotador.{nombre_archivo}')
        self.logger.setLevel(logging.INFO)
        
        if not self.logger.handlers:
            self.logger.addHandler(self.handler)


def generar_logs_intensivos(rotator, cantidad_mensajes=200):
    """
    Genera muchos mensajes de log rápidamente para forzar rotación
    
    Args:
        rotator: Instancia de LogRotator
        cantidad_mensajes: Número de mensajes a generar
    """
    print(f"\n🔄 Generando {cantidad_mensajes} mensajes de log...")
    
    for i in range(cantidad_mensajes):
        # Simular diferentes tipos de eventos
        tipo = random.choice(['debug', 'info', 'warning', 'error'])
        
        if tipo == 'debug':
            mensaje = f"Debug detallado: iteración {i}, valor={random.randint(1,100)}"
        elif tipo == 'info':
            mensaje = f"Procesando item {i}: operación exitosa"
        elif tipo == 'warning':
            mensaje = f"ADVERTENCIA: recurso bajo en item {i}, disponible={random.randint(0,10)}%"
        else:  # error
            mensaje = f"ERROR {random.randint(100, 999)}: Falló procesamiento del item {i}"
        
        rotator.escribir_mensaje(tipo, mensaje)
        
        # Pequeña pausa para simular procesamiento real
        if i % 50 == 0:
            print(f"  Generados {i}/{cantidad_mensajes} mensajes...")
    
    print(f"✅ Generación completada")


def simulador_tiempo_real():
    """Simula logs que crecen con el tiempo"""
    
    print("\n" + "="*50)
    print("SIMULADOR DE ROTACIÓN POR TIEMPO")
    print("="*50)
    
    # Crear rotator por tiempo (rota cada 5 segundos)
    rotator_tiempo = RotacionPorTiempo(
        nombre_archivo='simulacion',
        intervalo_segundos=5,
        backups=3
    )
    
    logger = rotator_tiempo.logger
    print("\n⏰ Generando logs con rotación cada 5 segundos...")
    print("   Presiona Ctrl+C para detener\n")
    
    try:
        contador = 0
        while True:
            contador += 1
            momento = time.strftime("%H:%M:%S")
            
            logger.info(f"Evento {contador} a las {momento}")
            print(f"  Log escrito: evento {contador} - {momento}")
            
            # Cada 3 logs, mostrar estado de archivos
            if contador % 3 == 0:
                archivos = os.listdir('logs')
                logs_relacionados = [f for f in archivos if f.startswith('simulacion_tiempo')]
                print(f"  📁 Archivos actuales: {logs_relacionados}")
            
            time.sleep(1)  # Esperar 1 segundo
    except KeyboardInterrupt:
        print(f"\n\n✅ Simulación detenida. Total logs escritos: {contador}")


def demostracion_rotacion_tamano():
    """Demostración de rotación basada en tamaño"""
    
    print("\n" + "="*50)
    print("DEMOSTRACIÓN DE ROTACIÓN POR TAMAÑO")
    print("="*50)
    
    # Crear rotator con tamaño máximo pequeño para ver rotación rápidamente
    print("\n📌 Configurando logs con tamaño máximo de 10 KB...")
    rotator = LogRotator(
        nombre_archivo='test_tamano',
        tamano_maximo_mb=0.01,  # 10 KB
        backups=3
    )
    
    # Mostrar estado inicial
    rotator.mostrar_estado_logs()
    
    # Generar logs hasta que rote múltiples veces
    print("\n📝 Generando logs hasta que se produzcan rotaciones...")
    
    for i in range(500):
        # Generar mensaje de tamaño variable
        mensaje = f"Registro #{i} " + "x" * (i % 50) + f" - Datos adicionales para llenar el log"
        rotator.escribir_mensaje('info', mensaje)
        
        # Mostrar estado cada 100 logs
        if i % 100 == 0 and i > 0:
            print(f"\n--- Después de {i} mensajes ---")
            rotator.mostrar_estado_logs()
    
    print("\n✅ Rotación completada")
    rotator.mostrar_estado_logs()


def analizar_rotacion():
    """Analiza los archivos generados por la rotación"""
    
    print("\n" + "="*50)
    print("ANÁLISIS DE ARCHIVOS DE LOG ROTADOS")
    print("="*50)
    
    if not os.path.exists('logs'):
        print("No se encontró directorio de logs")
        return
    
    archivos = os.listdir('logs')
    
    # Agrupar por tipo de rotación
    rotacion_tamano = [f for f in archivos if 'test_tamano' in f]
    rotacion_tiempo = [f for f in archivos if 'simulacion_tiempo' in f]
    
    print("\n📁 Rotación por Tamaño:")
    for archivo in sorted(rotacion_tamano):
        ruta = os.path.join('logs', archivo)
        tamaño = os.path.getsize(ruta)
        print(f"  • {archivo}: {tamaño:,} bytes ({tamaño/1024:.2f} KB)")
    
    print("\n⏰ Rotación por Tiempo:")
    for archivo in sorted(rotacion_tiempo)[-5:]:  # Últimos 5
        ruta = os.path.join('logs', archivo)
        tamaño = os.path.getsize(ruta)
        print(f"  • {archivo}: {tamaño:,} bytes ({tamaño/1024:.2f} KB)")
    
    # Calcular espacio total
    espacio_total = sum(os.path.getsize(os.path.join('logs', f)) for f in archivos if f.endswith('.log'))
    print(f"\n💾 Espacio total ocupado por logs: {espacio_total:,} bytes ({espacio_total/1024:.2f} KB)")


if __name__ == "__main__":
    print("="*50)
    print("EJERCICIO 15: ROTACIÓN DE LOGS")
    print("="*50)
    
    print("""
    📚 TIPOS DE ROTACIÓN:
    
    1. POR TAMAÑO (RotatingFileHandler):
       - Rota cuando el archivo supera cierto tamaño
       - Útil para logs con volumen variable
       - Permite mantener logs recientes en archivos manejables
    
    2. POR TIEMPO (TimedRotatingFileHandler):
       - Rota después de cierto intervalo
       - Útil para logs que crecen de forma predecible
       - Facilita la organización por día/hora
    
    VENTAJAS DE LA ROTACIÓN:
    ✓ Evita archivos de log enormes
    ✓ Facilita la limpieza de logs antiguos
    ✓ Mejora el rendimiento de escritura
    ✓ Permite comprimir/archivar logs históricos
    """)
    
    # Ejecutar demostraciones
    try:
        # Demostración de rotación por tamaño
        demostracion_rotacion_tamano()
        
        # Análisis de archivos generados
        analizar_rotacion()
        
        # Nota: La simulación por tiempo está comentada para no ejecutarse automáticamente
        print("\n" + "="*50)
        print("💡 EJECUTAR SIMULACIÓN POR TIEMPO:")
        print("="*50)
        print("Para ver la rotación por tiempo, descomenta la llamada a:")
        print("simulador_tiempo_real()")
        print("\nPresiona Ctrl+C para detener la simulación")
        
        # simulador_tiempo_real()  # Descomentar para probar
        
    except KeyboardInterrupt:
        print("\n\n✅ Demostración interrumpida por el usuario")
    except Exception as e:
        print(f"\n❌ Error: {e}")
    
    print("\n📝 Nota: Los logs generados se encuentran en el directorio 'logs/'")
```
### 003ejercicio_pytest_fixture.py
```python
"""
Ejercicio 16: Pytest con fixtures
Objetivo: Usar fixtures para compartir configuraciones y datos entre pruebas

Sentencias esenciales:
- @pytest.fixture: Decorador para definir fixtures
- Uso de fixture como parámetro en funciones de prueba
- Scope de fixtures (function, class, module, session)

¿Qué son los fixtures?
Recursos que se preparan antes de las pruebas y se limpian después,
evitando código repetido de configuración/limpieza.
"""

import pytest
import tempfile
import os
import json
from datetime import datetime

# ============================================
# FUNCIONES A PROBAR
# ============================================

class GestorTareas:
    """Gestor simple de tareas para demostrar fixtures"""
    
    def __init__(self, archivo_json=None):
        self.tareas = []
        self.archivo_json = archivo_json
        if archivo_json and os.path.exists(archivo_json):
            self.cargar_de_archivo()
    
    def agregar_tarea(self, titulo, prioridad='media'):
        tarea = {
            'id': len(self.tareas) + 1,
            'titulo': titulo,
            'prioridad': prioridad,
            'completada': False,
            'creada': datetime.now().isoformat()
        }
        self.tareas.append(tarea)
        return tarea
    
    def completar_tarea(self, tarea_id):
        for tarea in self.tareas:
            if tarea['id'] == tarea_id:
                tarea['completada'] = True
                return True
        return False
    
    def obtener_tareas_por_prioridad(self, prioridad):
        return [t for t in self.tareas if t['prioridad'] == prioridad]
    
    def guardar_en_archivo(self):
        if self.archivo_json:
            with open(self.archivo_json, 'w') as f:
                json.dump(self.tareas, f, indent=2)
    
    def cargar_de_archivo(self):
        with open(self.archivo_json, 'r') as f:
            self.tareas = json.load(f)


def calcular_precio_con_impuesto(precio_base, impuesto=0.21):
    """Calcula precio final aplicando impuesto"""
    return precio_base * (1 + impuesto)


# ============================================
# FIXTURES
# ============================================

@pytest.fixture
def gestor_vacio():
    """Fixture que retorna un GestorTareas vacío"""
    print("\n  🔧 Configurando gestor vacío")
    gestor = GestorTareas()
    yield gestor
    print("  🧹 Limpiando gestor vacío")


@pytest.fixture
def gestor_con_tareas():
    """Fixture que retorna un GestorTareas con tareas precargadas"""
    print("\n  🔧 Configurando gestor con tareas")
    gestor = GestorTareas()
    gestor.agregar_tarea("Comprar leche", "alta")
    gestor.agregar_tarea("Estudiar Python", "alta")
    gestor.agregar_tarea("Hacer ejercicio", "baja")
    gestor.agregar_tarea("Llamar a mamá", "media")
    yield gestor
    print("  🧹 Limpiando gestor con tareas")


@pytest.fixture
def archivo_temporal():
    """Fixture que crea un archivo temporal y lo limpia después"""
    print("\n  🔧 Creando archivo temporal")
    fd, path = tempfile.mkstemp(suffix='.json', prefix='tareas_')
    os.close(fd)
    
    yield path
    
    print(f"  🧹 Eliminando archivo temporal: {path}")
    if os.path.exists(path):
        os.unlink(path)


@pytest.fixture(scope="module")
def datos_comunes():
    """
    Fixture con scope 'module' - se crea una vez por módulo
    Útil para datos que no cambian entre pruebas
    """
    print("\n  🔧 Configurando datos comunes (una sola vez)")
    return {
        'precios_prueba': [10, 20, 30, 40, 50],
        'impuesto_base': 0.21,
        'usuario_test': "test_user"
    }


@pytest.fixture(autouse=True)
def registro_tiempo():
    """
    Fixture que se ejecuta automáticamente en cada prueba
    autouse=True: se usa sin necesidad de especificarlo
    """
    inicio = datetime.now()
    print(f"\n  ⏱️  Iniciando prueba a las {inicio.strftime('%H:%M:%S.%f')[:-3]}")
    yield
    fin = datetime.now()
    duracion = (fin - inicio).total_seconds()
    print(f"  ⏱️  Prueba finalizada en {duracion:.4f} segundos")


# ============================================
# PRUEBAS USANDO FIXTURES
# ============================================

def test_agregar_tarea(gestor_vacio):
    """Prueba agregar tarea usando fixture de gestor vacío"""
    print("    📝 Ejecutando test_agregar_tarea")
    
    tarea = gestor_vacio.agregar_tarea("Nueva tarea", "alta")
    
    assert len(gestor_vacio.tareas) == 1
    assert tarea['titulo'] == "Nueva tarea"
    assert tarea['prioridad'] == "alta"
    assert not tarea['completada']


def test_completar_tarea(gestor_con_tareas):
    """Prueba completar tarea usando fixture con datos precargados"""
    print("    📝 Ejecutando test_completar_tarea")
    
    # La primera tarea tiene ID 1
    resultado = gestor_con_tareas.completar_tarea(1)
    
    assert resultado == True
    assert gestor_con_tareas.tareas[0]['completada'] == True


def test_filtrar_por_prioridad(gestor_con_tareas):
    """Prueba filtrar tareas por prioridad"""
    print("    📝 Ejecutando test_filtrar_por_prioridad")
    
    tareas_alta = gestor_con_tareas.obtener_tareas_por_prioridad("alta")
    tareas_baja = gestor_con_tareas.obtener_tareas_por_prioridad("baja")
    
    assert len(tareas_alta) == 2
    assert len(tareas_baja) == 1
    assert all(t['prioridad'] == "alta" for t in tareas_alta)


def test_guardar_y_cargar(archivo_temporal):
    """Prueba guardar y cargar desde archivo usando archivo temporal"""
    print("    📝 Ejecutando test_guardar_y_cargar")
    
    # Crear gestor y guardar
    gestor1 = GestorTareas(archivo_temporal)
    gestor1.agregar_tarea("Tarea 1")
    gestor1.agregar_tarea("Tarea 2")
    gestor1.guardar_en_archivo()
    
    # Crear nuevo gestor que carga desde el archivo
    gestor2 = GestorTareas(archivo_temporal)
    
    assert len(gestor2.tareas) == 2
    assert gestor2.tareas[0]['titulo'] == "Tarea 1"
    assert gestor2.tareas[1]['titulo'] == "Tarea 2"


def test_calculo_impuestos(datos_comunes):
    """Prueba usando fixture con scope module"""
    print("    📝 Ejecutando test_calculo_impuestos")
    
    for precio in datos_comunes['precios_prueba']:
        resultado = calcular_precio_con_impuesto(precio, datos_comunes['impuesto_base'])
        esperado = precio * 1.21
        assert resultado == esperado


@pytest.mark.parametrize("precio,esperado", [
    (100, 121),
    (200, 242),
    (50, 60.5),
])
def test_con_fixture_y_parametrizacion(datos_comunes, precio, esperado):
    """
    Combinación de fixture con parametrización
    Las pruebas se ejecutan para cada combinación
    """
    print(f"    📝 Probando precio={precio}, esperado={esperado}")
    
    resultado = calcular_precio_con_impuesto(precio, datos_comunes['impuesto_base'])
    assert resultado == esperado


# ============================================
# FIXTURES CON DIFERENTES SCOPES
# ============================================

@pytest.fixture(scope="class")
def recurso_costoso():
    """Fixture que simula un recurso costoso de crear (una vez por clase)"""
    print("\n  💰 Creando recurso costoso (esto ocurre solo una vez)")
    return {"conexion": "base_datos_simulada", "cache": {}}


@pytest.fixture(scope="session")
def configuracion_global():
    """Fixture que se crea una vez por toda la sesión de pruebas"""
    print("\n  🌍 Configuración global (una vez por toda la ejecución)")
    return {"environment": "testing", "debug": True}


class TestConFixturesDeClase:
    """Demostración de fixtures con scope class"""
    
    def test_uno(self, recurso_costoso):
        print("    Ejecutando test_uno")
        assert recurso_costoso["conexion"] == "base_datos_simulada"
    
    def test_dos(self, recurso_costoso):
        print("    Ejecutando test_dos")
        assert recurso_costoso["conexion"] == "base_datos_simulada"


# ============================================
# EJECUCIÓN
# ============================================

if __name__ == "__main__":
    print("="*50)
    print("EJERCICIO 16: FIXTURES CON PYTEST")
    print("="*50)
    
    print("""
    📚 TIPOS DE SCOPES EN FIXTURES:
    
    1. function (default):
       - Se crea y destruye para cada prueba
       - Útil para datos que deben estar aislados
    
    2. class:
       - Una vez por clase de pruebas
       - Compartido entre métodos de la clase
    
    3. module:
       - Una vez por archivo de pruebas
       - Compartido entre todas las pruebas del módulo
    
    4. session:
       - Una vez por toda la ejecución de pytest
       - Compartido entre múltiples archivos
    
    BENEFICIOS DE FIXTURES:
    ✓ Eliminan código repetitivo de setup/teardown
    ✓ Permiten reutilizar configuraciones complejas
    ✓ Mejoran la legibilidad de las pruebas
    ✓ Facilitan el manejo de recursos (archivos, DB, etc.)
    
    EJECUTAR LAS PRUEBAS:
    pytest ejercicio16_pytest_fixture.py -v -s
    
    La opción -s muestra los prints (para ver los mensajes de fixtures)
    """)
    
    print("\n⚠️ Ejecuta el comando mencionado arriba para ver las pruebas en acción")
    print("   Las aserciones en este archivo se validan con pytest, no con ejecución directa")
```
