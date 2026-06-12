Instalar dependencias
```bach
# Instalar todas las dependencias del archivo
pip install -r requirements.txt

# En sistemas Linux/Mac a veces necesitas pip3
pip3 install -r requirements.txt

# En Windows (PowerShell)
python -m pip install -r requirements.txt
```
# 📁 Estructura del Backen - API REST
```bach
fastapi_mysql_examples/
│
├── config.py                 # Configuración de BD
├── models.py                 # Modelos Pydantic
├── database.py               # Conexión y operaciones DB
├── main.py                   # Aplicación principal
│
├── ejemplos/
│   ├── 01_hola_mundo.py
│   ├── 02_crud_basico.py
│   ├── 03_con_db.py
│   ├── 04_modelos_pydantic.py
│   ├── 05_path_params.py
│   ├── 06_query_params.py
│   ├── 07_body_request.py
│   ├── 08_validaciones.py
│   ├── 09_relaciones_join.py
│   ├── 10_paginacion.py
│   ├── 11_filtros_avanzados.py
│   ├── 12_operaciones_masivas.py
│   ├── 13_autenticacion_jwt.py
│   ├── 14_dependencias.py
│   ├── 15_middleware.py
│   ├── 16_excepciones.py
│   ├── 17_upload_files.py
│   ├── 18_background_tasks.py
│   ├── 19_websocket.py
│   └── 20_completo_ventas.py
│
├── requirements.txt
└── .env
```
### 🔧 Configuración inicial
requirements.txt
```bach
fastapi==0.104.1
uvicorn==0.24.0
mysql-connector-python==8.1.0
pydantic==2.4.2
python-dotenv==1.0.0
python-jose[cryptography]==3.3.0
passlib[bcrypt]==1.7.4
python-multipart==0.0.6
websockets==12.0
```
### .env
```bach
DB_HOST=localhost
DB_USER=root
DB_PASSWORD=tu_password
DB_NAME=api_exercises
SECRET_KEY=mi_secreto_super_seguro
```
### config.py
```python
import os
from dotenv import load_dotenv

load_dotenv()

DB_CONFIG = {
    'host': os.getenv('DB_HOST', 'localhost'),
    'user': os.getenv('DB_USER', 'root'),
    'password': os.getenv('DB_PASSWORD', ''),
    'database': os.getenv('DB_NAME', 'api_exercises')
}

SECRET_KEY = os.getenv('SECRET_KEY', 'mi_secreto_dev')
ALGORITHM = "HS256"
ACCESS_TOKEN_EXPIRE_MINUTES = 30
```
### database.py

```python
import mysql.connector
from mysql.connector import Error
from config import DB_CONFIG

def get_db_connection():
    """Retorna una conexión a MySQL"""
    try:
        conn = mysql.connector.connect(**DB_CONFIG)
        return conn
    except Error as e:
        print(f"Error de conexión: {e}")
        return None

def init_database():
    """Inicializa tablas necesarias"""
    conn = get_db_connection()
    cursor = conn.cursor()
    
    # Tabla de usuarios
    cursor.execute("""
        CREATE TABLE IF NOT EXISTS usuarios (
            id INT AUTO_INCREMENT PRIMARY KEY,
            name VARCHAR(100) NOT NULL,
            email VARCHAR(100) UNIQUE NOT NULL,
            password_hash VARCHAR(255),
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        )
    """)
    
    # Tabla de productos
    cursor.execute("""
        CREATE TABLE IF NOT EXISTS productos (
            id INT AUTO_INCREMENT PRIMARY KEY,
            nombre VARCHAR(100) NOT NULL,
            descripcion TEXT,
            precio DECIMAL(10,2) NOT NULL,
            stock INT DEFAULT 0,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        )
    """)
    
    # Tabla de ventas
    cursor.execute("""
        CREATE TABLE IF NOT EXISTS ventas (
            id INT AUTO_INCREMENT PRIMARY KEY,
            usuario_id INT,
            producto_id INT,
            cantidad INT,
            total DECIMAL(10,2),
            fecha TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            FOREIGN KEY (usuario_id) REFERENCES usuarios(id),
            FOREIGN KEY (producto_id) REFERENCES productos(id)
        )
    """)
    
    conn.commit()
    cursor.close()
    conn.close()
    print("✅ Base de datos inicializada")
```
### models.py
```python
from pydantic import BaseModel, Field, validator
from typing import Optional
from datetime import datetime

# Modelos para Usuario
class UsuarioBase(BaseModel):
    name: str = Field(..., min_length=2, max_length=100)
    email: str = Field(..., pattern=r'^[\w\.-]+@[\w\.-]+\.\w+$')

class UsuarioCreate(UsuarioBase):
    password: str = Field(..., min_length=6)

class UsuarioResponse(UsuarioBase):
    id: int
    created_at: datetime
    
    class Config:
        from_attributes = True

# Modelos para Producto
class ProductoBase(BaseModel):
    nombre: str = Field(..., min_length=1, max_length=100)
    descripcion: Optional[str] = None
    precio: float = Field(..., gt=0)
    stock: int = Field(0, ge=0)

class ProductoCreate(ProductoBase):
    pass

class ProductoResponse(ProductoBase):
    id: int
    created_at: datetime
    
    class Config:
        from_attributes = True

# Modelos para Venta
class VentaCreate(BaseModel):
    usuario_id: int
    producto_id: int
    cantidad: int = Field(..., gt=0)
    
    @validator('producto_id')
    def validate_producto(cls, v):
        if v <= 0:
            raise ValueError('producto_id debe ser positivo')
        return v

class VentaResponse(BaseModel):
    id: int
    usuario_id: int
    producto_id: int
    cantidad: int
    total: float
    fecha: datetime
    usuario_nombre: Optional[str] = None
    producto_nombre: Optional[str] = None
    
    class Config:
        from_attributes = True

# Token y Login
class Token(BaseModel):
    access_token: str
    token_type: str

class LoginRequest(BaseModel):
    email: str
    password: str
```
### 📝 Ejemplos (1-20)
### ejemplos/01_hola_mundo.py
```python
"""
Ejemplo 1: Hola Mundo con FastAPI
FastAPI - Endpoint básico
"""

from fastapi import FastAPI

app = FastAPI(title="Mi API", description="Ejemplo básico", version="1.0.0")

@app.get("/")
def root():
    return {"message": "Hola Mundo desde FastAPI!"}

@app.get("/health")
def health_check():
    return {"status": "ok", "service": "FastAPI"}

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
```
### ejemplos/02_crud_basico.py
```python
"""
Ejemplo 2: CRUD básico con MySQL
Endpoints: GET, POST, PUT, DELETE
Lee configuración de .env y consume la tabla productos

El 02_crud_basico.py no tiene definido un endpoint para la raíz (/). Las rutas disponibles son:
- GET /productos — listar productos
- POST /productos — crear producto
- GET /productos/{id} — obtener producto
- PUT /productos/{id} — actualizar producto
- DELETE /productos/{id} — eliminar producto
Solución: Accede a http://localhost:8000/productos en el navegador, o mejor aún, a la documentación interactiva en http://localhost:8000/docs.
"""

from fastapi import FastAPI, HTTPException
from typing import List
import mysql.connector
from config import DB_CONFIG

app = FastAPI()


def get_db():
    conn = mysql.connector.connect(**DB_CONFIG)
    return conn


@app.get("/productos")
def listar_productos():
    conn = get_db()
    cursor = conn.cursor(dictionary=True)
    cursor.execute("SELECT id, nombre, precio, stock FROM productos")
    productos = cursor.fetchall()
    cursor.close()
    conn.close()
    return productos


@app.get("/productos/{id}")
def obtener_producto(id: int):
    conn = get_db()
    cursor = conn.cursor(dictionary=True)
    cursor.execute(
        "SELECT id, nombre, precio, stock FROM productos WHERE id = %s", (id,)
    )
    producto = cursor.fetchone()
    cursor.close()
    conn.close()
    if not producto:
        raise HTTPException(status_code=404, detail="Producto no encontrado")
    return producto


@app.post("/productos", status_code=201)
def crear_producto(nombre: str, precio: float, stock: int = 0):
    conn = get_db()
    cursor = conn.cursor()
    cursor.execute(
        "INSERT INTO productos (nombre, precio, stock) VALUES (%s, %s, %s)",
        (nombre, precio, stock),
    )
    conn.commit()
    producto_id = cursor.lastrowid
    cursor.close()
    conn.close()
    return {"id": producto_id, "nombre": nombre, "precio": precio, "stock": stock}


@app.put("/productos/{id}")
def actualizar_producto(id: int, nombre: str, precio: float, stock: int = 0):
    conn = get_db()
    cursor = conn.cursor(dictionary=True)
    cursor.execute(
        "SELECT id FROM productos WHERE id = %s", (id,)
    )
    producto = cursor.fetchone()
    if not producto:
        cursor.close()
        conn.close()
        raise HTTPException(status_code=404, detail="Producto no encontrado")
    cursor.execute(
        "UPDATE productos SET nombre = %s, precio = %s, stock = %s WHERE id = %s",
        (nombre, precio, stock, id),
    )
    conn.commit()
    cursor.close()
    conn.close()
    return {"id": id, "nombre": nombre, "precio": precio, "stock": stock}


@app.delete("/productos/{id}")
def eliminar_producto(id: int):
    conn = get_db()
    cursor = conn.cursor(dictionary=True)
    cursor.execute(
        "SELECT id FROM productos WHERE id = %s", (id,)
    )
    producto = cursor.fetchone()
    if not producto:
        cursor.close()
        conn.close()
        raise HTTPException(status_code=404, detail="Producto no encontrado")
    cursor.execute("DELETE FROM productos WHERE id = %s", (id,))
    conn.commit()
    cursor.close()
    conn.close()
    return {"message": "Producto eliminado"}


if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, port=8000)

```
### ejemplos/03_con_db.py
```python
"""
Ejemplo 3: Conexión a MySQL
Endpoints que interactúan con base de datos
"""

from fastapi import FastAPI, HTTPException
from typing import List
import mysql.connector
from mysql.connector import Error

app = FastAPI()

DB_CONFIG = {
    'host': 'localhost',
    'user': 'root',
    'password': 'tu_password',
    'database': 'api_exercises'
}

def get_db():
    conn = mysql.connector.connect(**DB_CONFIG)
    return conn

@app.on_event("startup")
def init_db():
    conn = get_db()
    cursor = conn.cursor()
    cursor.execute("""
        CREATE TABLE IF NOT EXISTS usuarios (
            id INT AUTO_INCREMENT PRIMARY KEY,
            nombre VARCHAR(100),
            email VARCHAR(100)
        )
    """)
    conn.commit()
    cursor.close()
    conn.close()

@app.get("/usuarios")
def get_usuarios():
    conn = get_db()
    cursor = conn.cursor(dictionary=True)
    cursor.execute("SELECT * FROM usuarios")
    usuarios = cursor.fetchall()
    cursor.close()
    conn.close()
    return {"usuarios": usuarios}

@app.post("/usuarios")
def create_usuario(nombre: str, email: str):
    conn = get_db()
    cursor = conn.cursor()
    cursor.execute(
        "INSERT INTO usuarios (nombre, email) VALUES (%s, %s)",
        (nombre, email)
    )
    conn.commit()
    usuario_id = cursor.lastrowid
    cursor.close()
    conn.close()
    return {"id": usuario_id, "nombre": nombre, "email": email}

@app.get("/usuarios/{id}")
def get_usuario(id: int):
    conn = get_db()
    cursor = conn.cursor(dictionary=True)
    cursor.execute("SELECT * FROM usuarios WHERE id = %s", (id,))
    usuario = cursor.fetchone()
    cursor.close()
    conn.close()
    
    if not usuario:
        raise HTTPException(status_code=404, detail="Usuario no encontrado")
    return usuario

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, port=8000)
```
### ejemplos/04_modelos_pydantic.py
```python
"""
Ejemplo 4: Uso de modelos Pydantic
Validación automática de datos
"""

from fastapi import FastAPI, HTTPException
from pydantic import BaseModel, Field, validator, EmailStr
from typing import Optional
from datetime import datetime

app = FastAPI()

# Modelos Pydantic
class UsuarioCreate(BaseModel):
    nombre: str = Field(..., min_length=2, max_length=50, example="Juan Perez")
    email: EmailStr = Field(..., example="juan@email.com")
    edad: int = Field(..., ge=18, le=120, description="Edad entre 18 y 120")
    telefono: Optional[str] = Field(None, pattern=r'^\+?[\d\s-]{8,}$')
    
    @validator('nombre')
    def nombre_no_vacio(cls, v):
        if not v.strip():
            raise ValueError('El nombre no puede estar vacío')
        return v.title()
    
    class Config:
        json_schema_extra = {
            "example": {
                "nombre": "Maria Gomez",
                "email": "maria@email.com",
                "edad": 25,
                "telefono": "+5491123456789"
            }
        }

class UsuarioResponse(BaseModel):
    id: int
    nombre: str
    email: str
    edad: int
    registrado: datetime
    
    class Config:
        from_attributes = True

# Base de datos simulada
usuarios_db = []
contador = 1

@app.post("/usuarios", response_model=UsuarioResponse, status_code=201)
def crear_usuario(usuario: UsuarioCreate):
    global contador
    nuevo = {
        "id": contador,
        "nombre": usuario.nombre,
        "email": usuario.email,
        "edad": usuario.edad,
        "registrado": datetime.now()
    }
    usuarios_db.append(nuevo)
    contador += 1
    return nuevo

@app.get("/usuarios/{id}", response_model=UsuarioResponse)
def obtener_usuario(id: int):
    for u in usuarios_db:
        if u["id"] == id:
            return u
    raise HTTPException(status_code=404, detail="Usuario no encontrado")

@app.get("/validar-email/{email}")
def validar_email(email: EmailStr):
    return {"email_valido": email, "es_correcto": True}

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, port=8000)
```
### ejemplos/05_path_params.py
```python
"""
Ejemplo 5: Parámetros de ruta (Path Parameters)
Diferentes formas de capturar valores en la URL
"""

from fastapi import FastAPI, Path
from typing import Optional

app = FastAPI()

# Parámetros básicos
@app.get("/usuarios/{usuario_id}")
def get_usuario(usuario_id: int):
    return {"usuario_id": usuario_id, "tipo": "entero"}

@app.get("/productos/{slug}")
def get_producto_slug(slug: str):
    return {"slug": slug, "producto": f"Producto: {slug}"}

# Validación con Path
@app.get("/items/{item_id}")
def read_item(
    item_id: int = Path(..., title="ID del item", ge=1, le=1000),
    q: Optional[str] = None
):
    return {"item_id": item_id, "q": q}

# Múltiples parámetros
@app.get("/categorias/{categoria_id}/productos/{producto_id}")
def get_producto_en_categoria(
    categoria_id: int = Path(..., ge=1),
    producto_id: int = Path(..., ge=1)
):
    return {
        "categoria_id": categoria_id,
        "producto_id": producto_id,
        "mensaje": f"Producto {producto_id} de categoría {categoria_id}"
    }

# Parámetros con formato específico
@app.get("/fecha/{anio}/{mes}/{dia}")
def get_fecha(
    anio: int = Path(..., ge=2000, le=2100),
    mes: int = Path(..., ge=1, le=12),
    dia: int = Path(..., ge=1, le=31)
):
    return {"fecha": f"{anio}-{mes:02d}-{dia:02d}"}

# Path con regex
@app.get("/codigos/{codigo}")
def validar_codigo(
    codigo: str = Path(..., regex=r'^[A-Z]{2}-\d{4}$')
):
    return {"codigo": codigo, "valido": True}

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, port=8000)
```
ejemplos/06_query_params.py
```python
"""
Ejemplo 6: Parámetros de consulta (Query Parameters)
Filtros, paginación y opciones en la URL
"""

from fastapi import FastAPI, Query
from typing import Optional, List

app = FastAPI()

# Parámetros básicos
@app.get("/buscar")
def buscar(
    q: str,                    # Requerido
    limit: int = 10,           # Opcional con default
    offset: int = 0            # Opcional con default
):
    return {
        "query": q,
        "limit": limit,
        "offset": offset,
        "resultados": [f"Resultado {i+1}" for i in range(limit)]
    }

# Parámetros opcionales
@app.get("/productos")
def listar_productos(
    categoria: Optional[str] = None,
    precio_min: Optional[float] = None,
    precio_max: Optional[float] = None,
    orden: str = "nombre"
):
    return {
        "filtros": {
            "categoria": categoria,
            "precio_min": precio_min,
            "precio_max": precio_max
        },
        "orden": orden,
        "mensaje": "Filtros aplicados correctamente"
    }

# Validación avanzada con Query
@app.get("/usuarios")
def get_usuarios(
    page: int = Query(1, ge=1, description="Número de página"),
    per_page: int = Query(10, ge=1, le=100, description="Items por página"),
    search: Optional[str] = Query(None, min_length=2, max_length=50),
    active: bool = Query(True, description="Usuarios activos")
):
    return {
        "page": page,
        "per_page": per_page,
        "search": search,
        "active": active,
        "skip": (page - 1) * per_page,
        "limit": per_page
    }

# Lista de valores
@app.get("/filtros-multiples")
def filtros_multiples(
    tags: List[str] = Query([], description="Múltiples tags"),
    precios: List[float] = Query([], description="Rangos de precio")
):
    return {"tags": tags, "precios": precios}

# Parámetros booleanos
@app.get("/config")
def get_config(
    verbose: bool = Query(False, description="Modo verbose"),
    debug: bool = Query(False, description="Modo debug")
):
    return {"verbose": verbose, "debug": debug}

# Deprecated
@app.get("/old-endpoint")
def old_endpoint(
    param: str = Query(..., deprecated=True)
):
    return {"message": "Este parámetro está deprecado"}

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, port=8000)
```
### ejemplos/07_body_request.py
```python
"""
Ejemplo 7: Request Body (JSON)
Envío de datos complejos en POST/PUT
"""

from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
from typing import List, Optional
from datetime import datetime

app = FastAPI()

# Modelos anidados
class Direccion(BaseModel):
    calle: str
    numero: int
    ciudad: str
    codigo_postal: str

class UsuarioCreate(BaseModel):
    nombre: str
    email: str
    direccion: Direccion
    intereses: List[str]
    fecha_nacimiento: Optional[datetime] = None

class VentaItem(BaseModel):
    producto_id: int
    cantidad: int
    precio_unitario: float

class VentaCreate(BaseModel):
    usuario_id: int
    items: List[VentaItem]
    metodo_pago: str

# Endpoint con body simple
@app.post("/usuarios")
def crear_usuario(usuario: UsuarioCreate):
    return {
        "message": "Usuario creado",
        "usuario": usuario.dict(),
        "total_intereses": len(usuario.intereses)
    }

# Endpoint con body anidado
@app.post("/ventas")
def crear_venta(venta: VentaCreate):
    total = sum(item.cantidad * item.precio_unitario for item in venta.items)
    return {
        "venta_id": 123,
        "total": total,
        "items_count": len(venta.items),
        "metodo_pago": venta.metodo_pago
    }

# Múltiples cuerpos
@app.post("/procesar")
def procesar_datos(
    usuario: UsuarioCreate,
    config: dict,
    items: List[str]
):
    return {
        "usuario": usuario.nombre,
        "config": config,
        "items": items,
        "items_count": len(items)
    }

# Body + Path + Query
@app.put("/usuarios/{id}")
def actualizar_usuario(
    id: int,
    usuario: UsuarioCreate,
    confirmar: bool = True
):
    return {
        "id": id,
        "usuario": usuario.dict(),
        "confirmar": confirmar,
        "actualizado": datetime.now()
    }

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, port=8000)
```
### ejemplos/08_validaciones.py
```python
"""
Ejemplo 8: Validaciones avanzadas
Validaciones personalizadas y constraints
"""

from fastapi import FastAPI, HTTPException, Body
from pydantic import BaseModel, Field, validator, root_validator
from typing import Optional
from datetime import date, datetime

app = FastAPI()

class RegistroUsuario(BaseModel):
    username: str = Field(..., min_length=3, max_length=20, pattern=r'^[a-zA-Z0-9_]+$')
    email: str = Field(..., pattern=r'^[\w\.-]+@[\w\.-]+\.\w+$')
    password: str = Field(..., min_length=8)
    password_confirm: str
    edad: int = Field(..., ge=18, le=99)
    fecha_registro: datetime = Field(default_factory=datetime.now)
    
    # Validación individual
    @validator('username')
    def username_no_reservado(cls, v):
        reservados = ['admin', 'root', 'system']
        if v.lower() in reservados:
            raise ValueError('Username reservado')
        return v
    
    @validator('password')
    def password_fuerte(cls, v):
        if not any(c.isupper() for c in v):
            raise ValueError('La contraseña debe tener al menos una mayúscula')
        if not any(c.isdigit() for c in v):
            raise ValueError('La contraseña debe tener al menos un número')
        return v
    
    # Validación a nivel de todo el modelo
    @root_validator
    def validate_passwords_match(cls, values):
        if values.get('password') != values.get('password_confirm'):
            raise ValueError('Las contraseñas no coinciden')
        return values

class RangoPrecio(BaseModel):
    min: float = Field(..., ge=0)
    max: float = Field(..., ge=0)
    
    @root_validator
    def validate_range(cls, values):
        if values.get('min') > values.get('max'):
            raise ValueError('El precio mínimo no puede ser mayor al máximo')
        return values

@app.post("/registro")
def registrar(usuario: RegistroUsuario):
    return {
        "message": "Registro exitoso",
        "username": usuario.username,
        "email": usuario.email,
        "edad": usuario.edad
    }

@app.post("/validar-rango")
def validar_rango(rango: RangoPrecio):
    return {"rango_valido": True, "min": rango.min, "max": rango.max}

@app.post("/crear-con-body")
def crear_con_body(
    data: dict = Body(..., description="Datos a procesar"),
    version: str = Body("1.0", description="Versión de la API")
):
    return {"data": data, "version": version}

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, port=8000)
```
### ejemplos/09_relaciones_join.py
```python
"""
Ejemplo 9: Relaciones y JOINs en MySQL
Obtener datos relacionados de múltiples tablas
"""

from fastapi import FastAPI, HTTPException
from typing import List, Optional
from pydantic import BaseModel
from datetime import datetime
import mysql.connector

app = FastAPI()

DB_CONFIG = {
    'host': 'localhost',
    'user': 'root',
    'password': 'tu_password',
    'database': 'api_exercises'
}

# Modelos de respuesta
class UsuarioVentas(BaseModel):
    id: int
    nombre: str
    email: str
    total_gastado: float
    cantidad_ventas: int
    ultima_compra: Optional[datetime]

class VentaDetalle(BaseModel):
    id: int
    fecha: datetime
    producto: str
    cantidad: int
    precio_unitario: float
    total: float

class UsuarioConVentas(BaseModel):
    id: int
    nombre: str
    email: str
    ventas: List[VentaDetalle]
    total_gastado: float

def get_db():
    return mysql.connector.connect(**DB_CONFIG)

@app.on_event("startup")
def init():
    conn = get_db()
    cursor = conn.cursor()
    
    # Crear tablas de ejemplo
    cursor.execute("""
        CREATE TABLE IF NOT EXISTS usuarios (
            id INT AUTO_INCREMENT PRIMARY KEY,
            nombre VARCHAR(100),
            email VARCHAR(100)
        )
    """)
    
    cursor.execute("""
        CREATE TABLE IF NOT EXISTS ventas (
            id INT AUTO_INCREMENT PRIMARY KEY,
            usuario_id INT,
            producto VARCHAR(100),
            cantidad INT,
            precio_unitario DECIMAL(10,2),
            total DECIMAL(10,2),
            fecha TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            FOREIGN KEY (usuario_id) REFERENCES usuarios(id)
        )
    """)
    
    conn.commit()
    cursor.close()
    conn.close()

@app.get("/usuarios/{id}/resumen", response_model=UsuarioVentas)
def resumen_usuario(id: int):
    conn = get_db()
    cursor = conn.cursor(dictionary=True)
    
    query = """
        SELECT 
            u.id,
            u.nombre,
            u.email,
            COALESCE(SUM(v.total), 0) as total_gastado,
            COUNT(v.id) as cantidad_ventas,
            MAX(v.fecha) as ultima_compra
        FROM usuarios u
        LEFT JOIN ventas v ON u.id = v.usuario_id
        WHERE u.id = %s
        GROUP BY u.id
    """
    cursor.execute(query, (id,))
    resultado = cursor.fetchone()
    
    cursor.close()
    conn.close()
    
    if not resultado:
        raise HTTPException(status_code=404, detail="Usuario no encontrado")
    
    return resultado

@app.get("/usuarios/{id}/ventas", response_model=UsuarioConVentas)
def ventas_usuario(id: int):
    conn = get_db()
    cursor = conn.cursor(dictionary=True)
    
    # Datos del usuario
    cursor.execute("SELECT id, nombre, email FROM usuarios WHERE id = %s", (id,))
    usuario = cursor.fetchone()
    
    if not usuario:
        raise HTTPException(status_code=404, detail="Usuario no encontrado")
    
    # Ventas del usuario
    cursor.execute("""
        SELECT id, fecha, producto, cantidad, precio_unitario, total
        FROM ventas
        WHERE usuario_id = %s
        ORDER BY fecha DESC
    """, (id,))
    
    ventas = cursor.fetchall()
    
    # Calcular total
    total_gastado = sum(v['total'] for v in ventas) if ventas else 0
    
    cursor.close()
    conn.close()
    
    return {
        **usuario,
        "ventas": ventas,
        "total_gastado": total_gastado
    }

@app.get("/reportes/top-usuarios")
def top_usuarios(limit: int = 10):
    conn = get_db()
    cursor = conn.cursor(dictionary=True)
    
    query = """
        SELECT 
            u.id,
            u.nombre,
            u.email,
            COUNT(v.id) as total_compras,
            COALESCE(SUM(v.total), 0) as monto_total,
            AVG(v.total) as ticket_promedio
        FROM usuarios u
        LEFT JOIN ventas v ON u.id = v.usuario_id
        GROUP BY u.id
        ORDER BY monto_total DESC
        LIMIT %s
    """
    cursor.execute(query, (limit,))
    resultados = cursor.fetchall()
    
    cursor.close()
    conn.close()
    
    return {
        "top_usuarios": resultados,
        "limit": limit
    }

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, port=8000)
```
### ejemplos/10_paginacion.py
```python
"""
Ejemplo 10: Paginación profesional
Manejo de grandes volúmenes de datos
"""

from fastapi import FastAPI, Query, HTTPException
from typing import Optional, List, Dict, Any
from pydantic import BaseModel
from math import ceil
import mysql.connector

app = FastAPI()

DB_CONFIG = {
    'host': 'localhost',
    'user': 'root',
    'password': 'tu_password',
    'database': 'api_exercises'
}

class PaginationParams(BaseModel):
    page: int = Field(1, ge=1, description="Número de página")
    per_page: int = Field(20, ge=1, le=100, description="Items por página")
    sort_by: Optional[str] = Field(None, description="Campo para ordenar")
    sort_order: str = Field("DESC", pattern="^(ASC|DESC)$")

class PaginatedResponse(BaseModel):
    data: List[Any]
    total: int
    page: int
    per_page: int
    total_pages: int
    has_next: bool
    has_prev: bool
    next_page: Optional[int]
    prev_page: Optional[int]

def paginate_query(cursor, base_query: str, count_query: str, params: List, page: int, per_page: int):
    """Helper para paginar queries SQL"""
    offset = (page - 1) * per_page
    
    # Obtener total
    cursor.execute(count_query, params)
    total = cursor.fetchone()['total']
    
    # Obtener datos paginados
    paginated_query = f"{base_query} LIMIT %s OFFSET %s"
    cursor.execute(paginated_query, params + [per_page, offset])
    data = cursor.fetchall()
    
    total_pages = ceil(total / per_page) if per_page > 0 else 0
    
    return {
        'data': data,
        'total': total,
        'page': page,
        'per_page': per_page,
        'total_pages': total_pages,
        'has_next': page < total_pages,
        'has_prev': page > 1,
        'next_page': page + 1 if page < total_pages else None,
        'prev_page': page - 1 if page > 1 else None
    }

def get_db():
    return mysql.connector.connect(**DB_CONFIG)

@app.get("/ventas/paginadas", response_model=PaginatedResponse)
def get_ventas_paginadas(
    page: int = Query(1, ge=1),
    per_page: int = Query(20, ge=1, le=100),
    sort_by: Optional[str] = Query(None, regex="^(id|fecha|total)$"),
    sort_order: str = Query("DESC", regex="^(ASC|DESC)$"),
    usuario_id: Optional[int] = None,
    producto: Optional[str] = None
):
    conn = get_db()
    cursor = conn.cursor(dictionary=True)
    
    # Construir queries dinámicamente
    base_query = """
        SELECT id, fecha, producto, cantidad, total, usuario_id
        FROM ventas
        WHERE 1=1
    """
    count_query = "SELECT COUNT(*) as total FROM ventas WHERE 1=1"
    params = []
    
    if usuario_id:
        base_query += " AND usuario_id = %s"
        count_query += " AND usuario_id = %s"
        params.append(usuario_id)
    
    if producto:
        base_query += " AND producto LIKE %s"
        count_query += " AND producto LIKE %s"
        params.append(f"%{producto}%")
    
    if sort_by:
        base_query += f" ORDER BY {sort_by} {sort_order}"
    else:
        base_query += " ORDER BY fecha DESC"
    
    result = paginate_query(cursor, base_query, count_query, params, page, per_page)
    
    cursor.close()
    conn.close()
    
    return result

@app.get("/productos/paginados")
def get_productos_paginados(
    page: int = Query(1, ge=1),
    per_page: int = Query(10, ge=1, le=50),
    min_precio: Optional[float] = None,
    max_precio: Optional[float] = None,
    search: Optional[str] = None
):
    conn = get_db()
    cursor = conn.cursor(dictionary=True)
    
    base_query = "SELECT * FROM productos WHERE 1=1"
    count_query = "SELECT COUNT(*) as total FROM productos WHERE 1=1"
    params = []
    
    if min_precio:
        base_query += " AND precio >= %s"
        count_query += " AND precio >= %s"
        params.append(min_precio)
    
    if max_precio:
        base_query += " AND precio <= %s"
        count_query += " AND precio <= %s"
        params.append(max_precio)
    
    if search:
        base_query += " AND (nombre LIKE %s OR descripcion LIKE %s)"
        count_query += " AND (nombre LIKE %s OR descripcion LIKE %s)"
        search_term = f"%{search}%"
        params.extend([search_term, search_term])
    
    base_query += " ORDER BY id DESC"
    
    result = paginate_query(cursor, base_query, count_query, params, page, per_page)
    
    cursor.close()
    conn.close()
    
    # Agregar URLs de navegación
    base_url = "/productos/paginados"
    result['first_page_url'] = f"{base_url}?page=1&per_page={per_page}"
    result['last_page_url'] = f"{base_url}?page={result['total_pages']}&per_page={per_page}"
    
    return result

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, port=8000)
```
### ejemplos/11_filtros_avanzados.py
```python
"""
Ejemplo 11: Filtros avanzados y búsqueda
Múltiples criterios de búsqueda
"""

from fastapi import FastAPI, Query, HTTPException
from typing import Optional, List
from pydantic import BaseModel
from datetime import date, datetime
import mysql.connector

app = FastAPI()

DB_CONFIG = {
    'host': 'localhost',
    'user': 'root',
    'password': 'tu_password',
    'database': 'api_exercises'
}

class FiltrosVenta(BaseModel):
    usuario_id: Optional[int] = None
    producto: Optional[str] = None
    fecha_desde: Optional[date] = None
    fecha_hasta: Optional[date] = None
    total_min: Optional[float] = None
    total_max: Optional[float] = None
    cantidad_min: Optional[int] = None

def get_db():
    return mysql.connector.connect(**DB_CONFIG)

@app.get("/ventas/buscar")
def buscar_ventas(
    # Filtros directos
    usuario_id: Optional[int] = Query(None, description="ID del usuario"),
    producto: Optional[str] = Query(None, description="Nombre del producto"),
    fecha_desde: Optional
```
