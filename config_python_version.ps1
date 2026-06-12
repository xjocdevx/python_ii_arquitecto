# config_python_version.ps1
```bach
# 1. Descargar e instalar Pyenv de forma silenciosa
$url = "https://githubusercontent.com"
$output = "$env:TEMP\install-pyenv.ps1"
Invoke-WebRequest -UseBasicParsing -Uri $url -OutFile $output
& $output

# 2. Forzar la recarga de las nuevas variables de entorno en la sesión actual
$env:PYENV = "$env:USERPROFILE\.pyenv\pyenv-win\"
$env:Path = "$env:USERPROFILE\.pyenv\pyenv-win\bin;$env:USERPROFILE\.pyenv\pyenv-win\shims;" + $env:Path

# 3. Actualizar la lista de versiones disponibles
pyenv update

# 4. Instalar las versiones deseadas de Python (Modifica los números si requieres otras)
pyenv install 3.11.9
pyenv install 3.12.2

# 5. Definir la versión global predeterminada y aplicar cambios
pyenv global 3.11.9
pyenv rehash

# 6. Confirmación visual de éxito
Write-Host "----------------------------------------------" -ForegroundColor Green
Write-Host "¡Configuración completada con éxito en este equipo!" -ForegroundColor Green
python --version
Write-Host "----------------------------------------------" -ForegroundColor Green
```
