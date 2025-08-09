@echo off
setlocal EnableDelayedExpansion

echo ===============================================
echo    Crear Release de Prueba - GitHub Actions
echo ===============================================
echo.

REM Verificar si estamos en un repositorio git
git status >nul 2>&1
if errorlevel 1 (
    echo [ERROR] No estas en un repositorio git valido!
    echo Asegurate de ejecutar este script desde la carpeta del proyecto.
    pause
    exit /b 1
)

REM Obtener informacion del repositorio
for /f %%i in ('git rev-parse --short HEAD') do set current_commit=%%i
for /f %%i in ('git branch --show-current') do set current_branch=%%i

echo [INFO] Repositorio: Twitch Drops Miner
echo [INFO] Rama actual: %current_branch%
echo [INFO] Commit actual: %current_commit%
echo.

REM Verificar si hay cambios sin commitear
git diff --quiet
if errorlevel 1 (
    echo [WARNING] Tienes cambios sin commitear!
    echo Los siguientes archivos han cambiado:
    git diff --name-only
    echo.
    set /p continue="¿Continuar de todos modos? (y/N): "
    if /i not "!continue!"=="y" (
        echo Operacion cancelada.
        pause
        exit /b 1
    )
)

echo ===============================================
echo           CONFIGURACION DEL RELEASE
echo ===============================================
echo.

REM Obtener version actual
for /f "tokens=2 delims==" %%i in ('findstr "__version__" version.py') do (
    set current_version=%%i
    set current_version=!current_version: =!
    set current_version=!current_version:"=!
)

echo Version actual en version.py: %current_version%
echo.

REM Opciones de release
echo Selecciona el tipo de release:
echo 1. Release de Prueba (test-v{version})
echo 2. Release Oficial (v{version})
echo 3. Cancelar
echo.
set /p release_type="Tu seleccion (1-3): "

if "%release_type%"=="3" (
    echo Operacion cancelada.
    pause
    exit /b 1
)

if "%release_type%"=="1" (
    set tag_prefix=test-v
    set is_prerelease=true
    echo [INFO] Creando release de PRUEBA
) else if "%release_type%"=="2" (
    set tag_prefix=v
    set is_prerelease=false
    echo [INFO] Creando release OFICIAL
) else (
    echo [ERROR] Seleccion invalida!
    pause
    exit /b 1
)

echo.
REM Obtener version para el tag
echo Ingresa la version para el release (ejemplo: 1.0.0):
set /p version_input="Version: "

if "%version_input%"=="" (
    echo [ERROR] Version no puede estar vacia!
    pause
    exit /b 1
)

set full_tag=%tag_prefix%%version_input%
echo.
echo Tag que se creara: %full_tag%
echo Tipo: %release_type%
echo Pre-release: %is_prerelease%
echo.

REM Confirmacion final
set /p confirm="¿Estas seguro de crear este release? (y/N): "
if /i not "%confirm%"=="y" (
    echo Operacion cancelada.
    pause
    exit /b 1
)

echo.
echo ===============================================
echo          CREANDO RELEASE
echo ===============================================
echo.

REM Verificar si el tag ya existe
git tag | findstr /c:"%full_tag%" >nul 2>&1
if not errorlevel 1 (
    echo [WARNING] El tag %full_tag% ya existe!
    set /p overwrite="¿Sobrescribir el tag existente? (y/N): "
    if /i "!overwrite!"=="y" (
        echo [INFO] Eliminando tag existente...
        git tag -d %full_tag% >nul 2>&1
        git push origin --delete %full_tag% >nul 2>&1
    ) else (
        echo Operacion cancelada.
        pause
        exit /b 1
    )
)

REM Crear y empujar el tag
echo [INFO] Creando tag %full_tag%...
git tag -a %full_tag% -m "Release %full_tag%"
if errorlevel 1 (
    echo [ERROR] Error creando el tag!
    pause
    exit /b 1
)

echo [INFO] Empujando tag al repositorio...
git push origin %full_tag%
if errorlevel 1 (
    echo [ERROR] Error empujando el tag!
    echo Eliminando tag local...
    git tag -d %full_tag% >nul 2>&1
    pause
    exit /b 1
)

echo.
echo ===============================================
echo            RELEASE CREADO EXITOSAMENTE!
echo ===============================================
echo.
echo Tag: %full_tag%
echo Tipo: %release_type%
echo.
echo El GitHub Action se esta ejecutando automaticamente.
echo.
echo Para verificar el progreso:
echo 1. Ve a: https://github.com/%USERNAME%/TwitchDropsMiner/actions
echo 2. Busca el workflow "Create Release"
echo 3. El release aparecera en: https://github.com/%USERNAME%/TwitchDropsMiner/releases
echo.
echo Tiempo estimado de build: 5-10 minutos
echo.

REM Preguntar si abrir el navegador
set /p open_browser="¿Abrir la pagina de Actions en el navegador? (y/N): "
if /i "%open_browser%"=="y" (
    start "" "https://github.com/%USERNAME%/TwitchDropsMiner/actions"
)

echo.
echo ===============================================
echo                SIGUIENTES PASOS
echo ===============================================
echo.
if "%is_prerelease%"=="true" (
    echo Este es un RELEASE DE PRUEBA:
    echo - Se marcara automaticamente como pre-release
    echo - Los releases de prueba antiguos se eliminaran automaticamente
    echo - Perfecto para testing antes del release oficial
) else (
    echo Este es un RELEASE OFICIAL:
    echo - Se marcara como "latest release"
    echo - Sera visible para todos los usuarios
    echo - Asegurate de que este completamente probado
)
echo.
echo Una vez completado el build:
echo 1. Descarga y prueba el ejecutable
echo 2. Verifica que funcione correctamente
echo 3. Si hay problemas, crea un nuevo tag con version incrementada
echo.

pause
