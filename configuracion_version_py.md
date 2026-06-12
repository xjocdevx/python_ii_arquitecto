# config_python_version.ps1
```bach
# Asegurar la conexión TLS para descargas seguras
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

# 1. Descargar e instalar Pyenv
Write-Host "Instalando Pyenv..." -ForegroundColor Cyan
$url = "https://githubusercontent.com"
$output = "$env:TEMP\install-pyenv.ps1"
Invoke-WebRequest -UseBasicParsing -Uri $url -OutFile $output
& $output

# 2. Cargar variables de entorno en la sesión actual
$env:PYENV = "$env:USERPROFILE\.pyenv\pyenv-win\"
$env:Path = "$env:USERPROFILE\.pyenv\pyenv-win\bin;$env:USERPROFILE\.pyenv\pyenv-win\shims;" + $env:Path

# 3. Actualizar e instalar versiones de Python
Write-Host "Descargando e instalando Python (Esto puede tardar)..." -ForegroundColor Cyan
pyenv update
pyenv install 3.11.9
pyenv install 3.12.2

# 4. Configurar versión por defecto
pyenv global 3.11.9
pyenv rehash

# 5. Verificación final
Write-Host "`n----------------------------------------------" -ForegroundColor Green
Write-Host "¡Configuración completada con éxito!" -ForegroundColor Green
python --version
Write-Host "----------------------------------------------" -ForegroundColor Green
Read-Host "Presiona Enter para cerrar esta ventana"
```
