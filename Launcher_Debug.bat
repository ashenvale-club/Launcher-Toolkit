@echo off
setlocal EnableDelayedExpansion
chcp 65001 >nul 2>&1
title Ashenvale Launcher - Modo Debug y Solución de Problemas

:: Configurar tamaño de ventana (120 columnas x 50 líneas)
mode con: cols=120 lines=50

color 0B

echo.
echo ╔════════════════════════════════════════════════════════════════╗
echo ║     ASHENVALE LAUNCHER - MODO DEBUG                           ║
echo ║     Herramienta de solución de problemas avanzada             ║
echo ╚════════════════════════════════════════════════════════════════╝
echo.

:: Detectar launcher
echo [*] Detectando launcher instalado...
set "LAUNCHER_PATH="
set "LAUNCHER_NAME="
set "FULL_LAUNCHER_PATH="

:: Buscar en registro HKLM
for /f "tokens=2*" %%a in ('reg query "HKLM\Software\Ashenvale\InstallLocation" /v "ManagerPath" 2^>nul ^| find "ManagerPath"') do set "LAUNCHER_PATH=%%b"
for /f "tokens=2*" %%a in ('reg query "HKLM\Software\Ashenvale\InstallLocation" /v "ManagerName" 2^>nul ^| find "ManagerName"') do set "LAUNCHER_NAME=%%b"

:: Si no está en HKLM, buscar en HKCU
if not defined LAUNCHER_PATH (
    for /f "tokens=2*" %%a in ('reg query "HKCU\Software\Ashenvale\InstallLocation" /v "ManagerPath" 2^>nul ^| find "ManagerPath"') do set "LAUNCHER_PATH=%%b"
    for /f "tokens=2*" %%a in ('reg query "HKCU\Software\Ashenvale\InstallLocation" /v "ManagerName" 2^>nul ^| find "ManagerName"') do set "LAUNCHER_NAME=%%b"
)

:: Verificar si existe
if defined LAUNCHER_PATH if defined LAUNCHER_NAME (
    set "FULL_LAUNCHER_PATH=%LAUNCHER_PATH%\%LAUNCHER_NAME%"
    if exist "!FULL_LAUNCHER_PATH!" (
        echo [✓] Launcher detectado: !FULL_LAUNCHER_PATH!
        goto :MENU
    )
)

:: Buscar en rutas conocidas si no está en registro
echo [*] Buscando en rutas conocidas...
for %%P in (
    "%PROGRAMFILES%\AshenvaleLauncher\AshenvaleLauncher.exe"
    "%LOCALAPPDATA%\Programs\AshenvaleLauncher\AshenvaleLauncher.exe"
    "%PROGRAMFILES%\l2ashenvale\l2ashenvale.exe"
    "%LOCALAPPDATA%\Programs\l2ashenvale\l2ashenvale.exe"
) do (
    if exist "%%~P" (
        set "FULL_LAUNCHER_PATH=%%~P"
        echo [✓] Launcher encontrado: %%~P
        goto :MENU
    )
)

:: Si no se encuentra
echo [!] No se detectó el launcher automáticamente
echo.
set /p "FULL_LAUNCHER_PATH=Ingrese la ruta completa del launcher: "
if not exist "!FULL_LAUNCHER_PATH!" (
    echo [X] El archivo no existe
    pause
    exit /b 1
)

:MENU
echo.
echo ════════════════════════════════════════════════════════════════════
echo                     MENÚ DE OPCIONES DEBUG
echo ════════════════════════════════════════════════════════════════════
echo.
echo  [1] Modo Seguro (Sin GPU)
echo      Desactiva aceleración por hardware
echo.
echo  [2] Modo Debug Completo
echo      Habilita consola de desarrollador y logs detallados
echo.
echo  [3] Modo Sin Sandbox
echo      Útil para problemas de permisos
echo.
echo  [4] Modo Offline
echo      Ejecuta sin verificar actualizaciones
echo.
echo  [5] Limpiar Caché y Ejecutar Normal
echo      Limpia todos los temporales y ejecuta normalmente
echo.
echo  [6] Modo Diagnóstico Completo
echo      Todos los parámetros de debug activos
echo.
echo  [7] Reparar Registro de Windows
echo      Reinstala las entradas del registro
echo.
echo  [8] Ver Logs del Launcher
echo      Abre la carpeta de logs
echo.
echo  [0] Salir
echo.
echo ════════════════════════════════════════════════════════════════════
echo.
set /p "opcion=Seleccione una opción (0-8): "

if "%opcion%"=="0" exit /b 0
if "%opcion%"=="1" goto :MODO_SEGURO
if "%opcion%"=="2" goto :MODO_DEBUG
if "%opcion%"=="3" goto :MODO_NOSANDBOX
if "%opcion%"=="4" goto :MODO_OFFLINE
if "%opcion%"=="5" goto :LIMPIAR_EJECUTAR
if "%opcion%"=="6" goto :MODO_COMPLETO
if "%opcion%"=="7" goto :REPARAR_REGISTRO
if "%opcion%"=="8" goto :VER_LOGS

echo [!] Opción no válida
timeout /t 2 >nul
goto :MENU

:MODO_SEGURO
echo.
echo [*] Iniciando en Modo Seguro (Sin GPU)...
echo [*] Parámetros: --disable-gpu --disable-software-rasterizer
echo.
start "" "!FULL_LAUNCHER_PATH!" --disable-gpu --disable-software-rasterizer
goto :FIN

:MODO_DEBUG
echo.
echo [*] Iniciando en Modo Debug...
echo [*] Parámetros: --remote-debugging-port=9222 --enable-logging --v=1
echo.
echo La consola de debug estará disponible en: http://localhost:9222
echo.
start "" "!FULL_LAUNCHER_PATH!" --remote-debugging-port=9222 --enable-logging --v=1
goto :FIN

:MODO_NOSANDBOX
echo.
echo [*] Iniciando sin Sandbox...
echo [*] Parámetros: --no-sandbox --disable-setuid-sandbox
echo.
start "" "!FULL_LAUNCHER_PATH!" --no-sandbox --disable-setuid-sandbox
goto :FIN

:MODO_OFFLINE
echo.
echo [*] Iniciando en Modo Offline...
echo [*] Parámetros: --disable-background-networking --disable-sync
echo.
start "" "!FULL_LAUNCHER_PATH!" --disable-background-networking --disable-sync
goto :FIN

:LIMPIAR_EJECUTAR
echo.
echo [*] Limpiando caché...

:: Limpiar carpetas nuevas
rd /s /q "%APPDATA%\l2ashenvale\Cache" 2>nul
rd /s /q "%APPDATA%\l2ashenvale\GPUCache" 2>nul
rd /s /q "%APPDATA%\l2ashenvale\Code Cache" 2>nul
rd /s /q "%LOCALAPPDATA%\l2ashenvale-updater\cache" 2>nul
del /q "%APPDATA%\l2ashenvale\*.log" 2>nul

:: Limpiar carpetas antiguas
rd /s /q "%APPDATA%\AshenvaleLauncher\Cache" 2>nul
rd /s /q "%APPDATA%\AshenvaleLauncher\GPUCache" 2>nul
rd /s /q "%APPDATA%\AshenvaleLauncher\Code Cache" 2>nul
rd /s /q "%LOCALAPPDATA%\AshenvaleLauncher" 2>nul

echo [✓] Caché limpiado
echo.
echo [*] Iniciando launcher normalmente...
start "" "!FULL_LAUNCHER_PATH!"
goto :FIN

:MODO_COMPLETO
echo.
echo [*] Iniciando en Modo Diagnóstico Completo...
echo [*] Todos los parámetros de debug activos
echo.
echo Parámetros aplicados:
echo - Sin aceleración GPU
echo - Sin sandbox
echo - Puerto debug 9222
echo - Logs detallados
echo - Sin verificación de certificados
echo.
start "" "!FULL_LAUNCHER_PATH!" --disable-gpu --no-sandbox --remote-debugging-port=9222 --enable-logging --v=1 --ignore-certificate-errors --disable-web-security
echo.
echo Debug console: http://localhost:9222
goto :FIN

:REPARAR_REGISTRO
echo.
echo [*] Reparando entradas del registro...

:: Obtener la carpeta del launcher
for %%F in ("!FULL_LAUNCHER_PATH!") do (
    set "LAUNCHER_DIR=%%~dpF"
    set "LAUNCHER_EXE=%%~nxF"
)

:: Eliminar la barra final si existe
if "!LAUNCHER_DIR:~-1!"=="\" set "LAUNCHER_DIR=!LAUNCHER_DIR:~0,-1!"

echo [*] Registrando en HKCU...
reg add "HKCU\Software\Ashenvale\InstallLocation" /v "ManagerPath" /t REG_SZ /d "!LAUNCHER_DIR!" /f >nul 2>&1
reg add "HKCU\Software\Ashenvale\InstallLocation" /v "ManagerName" /t REG_SZ /d "!LAUNCHER_EXE!" /f >nul 2>&1

:: Intentar registrar en HKLM (requiere admin)
echo [*] Intentando registrar en HKLM (requiere permisos de admin)...
reg add "HKLM\Software\Ashenvale\InstallLocation" /v "ManagerPath" /t REG_SZ /d "!LAUNCHER_DIR!" /f >nul 2>&1
if %errorlevel% equ 0 (
    reg add "HKLM\Software\Ashenvale\InstallLocation" /v "ManagerName" /t REG_SZ /d "!LAUNCHER_EXE!" /f >nul 2>&1
    echo [✓] Registro HKLM actualizado
) else (
    echo [!] No se pudo actualizar HKLM (requiere ejecutar como administrador)
)

echo [✓] Registro reparado
pause
goto :MENU

:VER_LOGS
echo.
echo [*] Abriendo carpeta de logs...

:: Intentar abrir carpetas de logs
if exist "%APPDATA%\l2ashenvale" (
    explorer "%APPDATA%\l2ashenvale"
) else if exist "%APPDATA%\AshenvaleLauncher" (
    explorer "%APPDATA%\AshenvaleLauncher"
) else (
    echo [!] No se encontró la carpeta de datos del launcher
    pause
)
goto :MENU

:FIN
echo.
echo ════════════════════════════════════════════════════════════════════
echo.
echo Launcher ejecutado con parámetros especiales.
echo.
echo Si el problema persiste:
echo 1. Ejecute Diagnostico_Launcher_v3.bat para generar un informe
echo 2. Ejecute Fix_Launcher_Universal_v2.bat como Administrador
echo 3. Contacte al soporte con el archivo de diagnóstico
echo.
pause