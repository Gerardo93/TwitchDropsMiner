@echo off
setlocal EnableDelayedExpansion

echo ===============================================
echo     Crear Release de Prueba con Seguridad Mejorada
echo ===============================================
echo.

REM Verificar si estamos en un repositorio git
git status >nul 2>&1
if errorlevel 1 (
    echo [ERROR] No estas en un repositorio git valido!
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

echo ===============================================
echo           MEJORAS DE SEGURIDAD IMPLEMENTADAS
echo ===============================================
echo.
echo ✅ Escaneo de dependencias por vulnerabilidades
echo ✅ Análisis estático de código con Bandit
echo ✅ UPX desactivado (evita falsos positivos de antivirus)
echo ✅ Preparado para firma digital de código
echo ✅ Reportes de seguridad incluidos
echo ✅ Verificación de integridad del ejecutable
echo.

echo ===============================================
echo           CREAR RELEASE DE PRUEBA
echo ===============================================
echo.

REM Generar version automaticamente basada en fecha y commit
for /f "tokens=1-3 delims=/ " %%a in ('date /t') do set current_date=%%c.%%b.%%a
for /f "tokens=1-2 delims=: " %%a in ('time /t') do set current_time=%%a.%%b
set auto_version=test-v1.0.0-%current_commit%

echo Se creará un release de prueba con las siguientes características:
echo.
echo 📦 CONTENIDO DEL RELEASE:
echo   - Ejecutable Windows (sin UPX, más compatible)
echo   - Manual de usuario
echo   - Información detallada del build
echo   - Reportes de seguridad
echo.
echo 🛡️ SEGURIDAD:
echo   - Dependencias escaneadas por vulnerabilidades
echo   - Código analizado estáticamente
echo   - Ejecutable sin compresión (evita antivirus)
echo   - Listo para firma digital (pendiente certificado)
echo.
echo 🏷️ TAG SUGERIDO: %auto_version%
echo.

set /p use_auto="¿Usar el tag automático? (Y/n): "
if /i "%use_auto%"=="n" (
    set /p custom_version="Ingresa tu versión personalizada (ej: test-v1.2.0): "
    set release_tag=!custom_version!
) else (
    set release_tag=%auto_version%
)

echo.
echo Tag final: %release_tag%
echo.

set /p final_confirm="¿Crear release de prueba con seguridad mejorada? (Y/n): "
if /i "%final_confirm%"=="n" (
    echo Operación cancelada.
    pause
    exit /b 1
)

echo.
echo ===============================================
echo          CREANDO RELEASE SEGURO
echo ===============================================
echo.

REM Verificar si el tag ya existe
git tag | findstr /c:"%release_tag%" >nul 2>&1
if not errorlevel 1 (
    echo [WARNING] El tag %release_tag% ya existe!
    set /p overwrite="¿Sobrescribir? (y/N): "
    if /i "!overwrite!"=="y" (
        echo [INFO] Eliminando tag existente...
        git tag -d %release_tag% >nul 2>&1
        git push origin --delete %release_tag% >nul 2>&1
    ) else (
        echo Operación cancelada.
        pause
        exit /b 1
    )
)

REM Crear y empujar el tag
echo [INFO] Creando tag %release_tag%...
git tag -a %release_tag% -m "Security-enhanced release %release_tag%"
if errorlevel 1 (
    echo [ERROR] Error creando el tag!
    pause
    exit /b 1
)

echo [INFO] Empujando tag al repositorio...
git push origin %release_tag%
if errorlevel 1 (
    echo [ERROR] Error empujando el tag!
    git tag -d %release_tag% >nul 2>&1
    pause
    exit /b 1
)

echo.
echo ===============================================
echo            RELEASE SEGURO CREADO!
echo ===============================================
echo.
echo ✅ Tag creado: %release_tag%
echo ✅ Workflow de seguridad iniciado
echo.
echo 🚀 EL WORKFLOW INCLUIRÁ:
echo.
echo 1️⃣ ANÁLISIS DE SEGURIDAD:
echo    - Escaneo de dependencias (Safety)
echo    - Análisis estático de código (Bandit)
echo    - Reportes detallados
echo.
echo 2️⃣ BUILD SEGURO:
echo    - Sin UPX (compatible con antivirus)
echo    - Verificación de integridad
echo    - Información detallada del build
echo.
echo 3️⃣ RELEASE CON SEGURIDAD MEJORADA:
echo    - Ejecutable verificado
echo    - Reportes de seguridad incluidos
echo    - Notas detalladas de seguridad
echo.
echo ⏱️  Tiempo estimado: 8-12 minutos
echo.

echo Para monitorear el progreso:
echo 1. GitHub Actions: https://github.com/%USERNAME%/TwitchDropsMiner/actions
echo 2. Releases: https://github.com/%USERNAME%/TwitchDropsMiner/releases
echo.

set /p open_actions="¿Abrir GitHub Actions en el navegador? (Y/n): "
if /i not "%open_actions%"=="n" (
    start "" "https://github.com/%USERNAME%/TwitchDropsMiner/actions"
)

echo.
echo ===============================================
echo                  NOTAS FINALES
echo ===============================================
echo.
echo 🔍 VERIFICACIÓN POST-BUILD:
echo   - Descarga el ejecutable y pruébalo
echo   - Revisa los reportes de seguridad
echo   - Verifica que no hay alertas de antivirus
echo.
echo 🛡️ MEJORAS VS VERSION ANTERIOR:
echo   - Mayor compatibilidad con antivirus
echo   - Transparencia total de seguridad
echo   - Reportes automáticos de vulnerabilidades
echo.
echo 🎯 PRÓXIMOS PASOS SUGERIDOS:
echo   - Si todo funciona bien, considera release oficial
echo   - Evalúa obtener certificado para firma digital
echo   - Revisa los reportes de seguridad generados
echo.

pause
