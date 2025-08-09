@echo off
setlocal EnableDelayedExpansion

echo ===============================================
echo    Twitch Drops Miner - Local Build Test
echo ===============================================
echo.

REM Get the directory path of the script
set "dirpath=%~dp0"
if "%dirpath:~-1%" == "\" set "dirpath=%dirpath:~0,-1%"

echo [INFO] Working directory: %dirpath%
echo.

REM Check Python installation
echo [STEP 1/7] Checking Python installation...
python --version >nul 2>&1
if errorlevel 1 (
    echo [ERROR] Python not found! Please install Python 3.10 or higher.
    pause
    exit /b 1
)

for /f "tokens=2" %%i in ('python --version 2^>^&1') do set python_version=%%i
echo [OK] Python %python_version% found

REM Check Python version
echo.
echo [STEP 2/7] Validating Python version...
python -c "import sys; exit(0 if sys.version_info >= (3, 10) else 1)" >nul 2>&1
if errorlevel 1 (
    echo [ERROR] Python 3.10 or higher is required!
    pause
    exit /b 1
)
echo [OK] Python version is compatible

REM Install dependencies
echo.
echo [STEP 3/7] Installing dependencies...
python -m pip install --upgrade pip wheel --quiet
if errorlevel 1 (
    echo [ERROR] Failed to upgrade pip and wheel
    pause
    exit /b 1
)

python -m pip install -r requirements.txt --quiet
if errorlevel 1 (
    echo [ERROR] Failed to install requirements
    pause
    exit /b 1
)

python -m pip install pyinstaller --quiet
if errorlevel 1 (
    echo [ERROR] Failed to install PyInstaller
    pause
    exit /b 1
)
echo [OK] Dependencies installed

REM Validate language files
echo.
echo [STEP 4/7] Validating language files...
set validation_failed=0
for %%f in (lang\*.json) do (
    python -m json.tool "%%f" >nul 2>&1
    if errorlevel 1 (
        echo [ERROR] Invalid JSON in %%f
        set validation_failed=1
    ) else (
        echo [OK] %%f
    )
)

if !validation_failed! == 1 (
    echo [ERROR] Some language files failed validation
    pause
    exit /b 1
)
echo [OK] All language files valid

REM Update version for testing
echo.
echo [STEP 5/7] Updating version for local build...
for /f %%i in ('git rev-parse --short HEAD 2^>nul ^|^| echo "local"') do set git_hash=%%i
echo __version__ = "16.dev.%git_hash%" > version_backup.py
copy version.py version_backup.py >nul 2>&1
echo __version__ = "16.dev.%git_hash%" > version.py
echo [OK] Version updated to 16.dev.%git_hash%

REM Build executable
echo.
echo [STEP 6/7] Building executable with PyInstaller...
echo [INFO] This may take several minutes...

pyinstaller build.spec --log-level=WARN
if errorlevel 1 (
    echo [ERROR] PyInstaller build failed!
    if exist version_backup.py (
        move version_backup.py version.py >nul 2>&1
    )
    pause
    exit /b 1
)

if not exist "dist\*.exe" (
    echo [ERROR] No executable found in dist folder!
    if exist version_backup.py (
        move version_backup.py version.py >nul 2>&1
    )
    pause
    exit /b 1
)

echo [OK] Build completed successfully

REM Create test package
echo.
echo [STEP 7/7] Creating test package...
set package_name=Twitch_Drops_Miner_Local_Test
if exist "%package_name%" rmdir /s /q "%package_name%"
mkdir "%package_name%"

copy "dist\*.exe" "%package_name%\" >nul 2>&1
if exist "manual.txt" copy "manual.txt" "%package_name%\" >nul 2>&1

REM Create build info
(
echo Build Type: Local Test Build
echo Build Date: %date% %time%
echo Git Hash: %git_hash%
echo Python Version: %python_version%
echo Builder: %USERNAME%
) > "%package_name%\BUILD_INFO.txt"

REM Get executable size
for %%f in ("%package_name%\*.exe") do (
    set /a size_mb=%%~zf / 1048576
    echo [INFO] Executable size: !size_mb! MB
    echo Executable Size: !size_mb! MB >> "%package_name%\BUILD_INFO.txt"
)

echo [OK] Test package created in %package_name%\

REM Restore original version
if exist version_backup.py (
    move version_backup.py version.py >nul 2>&1
)

echo.
echo ===============================================
echo             BUILD COMPLETED! 
echo ===============================================
echo.
echo Package location: %dirpath%\%package_name%\
echo.
echo To test:
echo 1. Go to the %package_name% folder
echo 2. Run the .exe file
echo 3. Check BUILD_INFO.txt for build details
echo.
echo Note: This is a local test build, not for distribution
echo.

REM Ask if user wants to run the executable
set /p run_exe="Do you want to run the executable now? (y/N): "
if /i "%run_exe%"=="y" (
    echo.
    echo [INFO] Starting executable...
    start "" "%package_name%\Twitch Drops Miner (by DevilXD).exe"
    echo [INFO] Executable started. Check if it opens properly.
)

echo.
echo Press any key to exit...
pause >nul
