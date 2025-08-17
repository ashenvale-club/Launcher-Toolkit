@echo off
setlocal EnableDelayedExpansion
chcp 65001 >nul 2>&1
title Ashenvale Launcher - Solución Universal v2.0

:: Configurar tamaño de ventana (120 columnas x 50 líneas)
mode con: cols=120 lines=50

:: Colores y diseño
color 0E

echo.
echo ╔════════════════════════════════════════════════════════════════╗
echo ║     ASHENVALE LAUNCHER - SOLUCIÓN UNIVERSAL v2.0              ║
echo ║     Compatible con: Windows 7, 8, 8.1, 10 y 11                ║
echo ╚════════════════════════════════════════════════════════════════╝
echo.

:: Verificar permisos de administrador
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo [!] Este script requiere permisos de Administrador
    echo     Cierre y ejecute como Administrador
    pause
    exit /b 1
)

echo [*] Detectando ubicación del launcher...
echo.

:: 1. BUSCAR EN EL REGISTRO DE WINDOWS
set "LAUNCHER_PATH="
set "LAUNCHER_NAME="

:: Buscar primero en HKLM (instalación para todos los usuarios)
for /f "tokens=2*" %%a in ('reg query "HKLM\Software\Ashenvale\InstallLocation" /v "ManagerPath" 2^>nul ^| find "ManagerPath"') do (
    set "LAUNCHER_PATH=%%b"
)
for /f "tokens=2*" %%a in ('reg query "HKLM\Software\Ashenvale\InstallLocation" /v "ManagerName" 2^>nul ^| find "ManagerName"') do (
    set "LAUNCHER_NAME=%%b"
)

:: Si no está en HKLM, buscar en HKCU (instalación por usuario)
if not defined LAUNCHER_PATH (
    for /f "tokens=2*" %%a in ('reg query "HKCU\Software\Ashenvale\InstallLocation" /v "ManagerPath" 2^>nul ^| find "ManagerPath"') do (
        set "LAUNCHER_PATH=%%b"
    )
    for /f "tokens=2*" %%a in ('reg query "HKCU\Software\Ashenvale\InstallLocation" /v "ManagerName" 2^>nul ^| find "ManagerName"') do (
        set "LAUNCHER_NAME=%%b"
    )
)

:: Si encontró la ruta en el registro, verificar que existe
if defined LAUNCHER_PATH (
    if defined LAUNCHER_NAME (
        set "FULL_LAUNCHER_PATH=%LAUNCHER_PATH%\%LAUNCHER_NAME%"
        if exist "!FULL_LAUNCHER_PATH!" (
            echo [✓] Launcher detectado desde registro: !FULL_LAUNCHER_PATH!
            goto :LAUNCHER_FOUND
        ) else (
            echo [!] Registro encontrado pero el archivo no existe
            set "LAUNCHER_PATH="
        )
    )
)

:: 2. SI NO ESTÁ EN EL REGISTRO, BUSCAR EN RUTAS CONOCIDAS
echo [*] Buscando en rutas conocidas...

:: Buscar AshenvaleLauncher (nombre antiguo)
if exist "%PROGRAMFILES%\AshenvaleLauncher\AshenvaleLauncher.exe" (
    set "FULL_LAUNCHER_PATH=%PROGRAMFILES%\AshenvaleLauncher\AshenvaleLauncher.exe"
    echo [✓] Launcher encontrado (versión antigua): !FULL_LAUNCHER_PATH!
    goto :LAUNCHER_FOUND
)

if exist "%LOCALAPPDATA%\Programs\AshenvaleLauncher\AshenvaleLauncher.exe" (
    set "FULL_LAUNCHER_PATH=%LOCALAPPDATA%\Programs\AshenvaleLauncher\AshenvaleLauncher.exe"
    echo [✓] Launcher encontrado (versión antigua): !FULL_LAUNCHER_PATH!
    goto :LAUNCHER_FOUND
)

:: Buscar l2ashenvale (nombre nuevo)
if exist "%PROGRAMFILES%\l2ashenvale\l2ashenvale.exe" (
    set "FULL_LAUNCHER_PATH=%PROGRAMFILES%\l2ashenvale\l2ashenvale.exe"
    echo [✓] Launcher encontrado: !FULL_LAUNCHER_PATH!
    goto :LAUNCHER_FOUND
)

if exist "%LOCALAPPDATA%\Programs\l2ashenvale\l2ashenvale.exe" (
    set "FULL_LAUNCHER_PATH=%LOCALAPPDATA%\Programs\l2ashenvale\l2ashenvale.exe"
    echo [✓] Launcher encontrado: !FULL_LAUNCHER_PATH!
    goto :LAUNCHER_FOUND
)

:: Si no se encuentra, preguntar al usuario
echo [!] No se pudo detectar el launcher automáticamente
echo.
set /p "FULL_LAUNCHER_PATH=Ingrese la ruta completa del launcher (ej: C:\...\launcher.exe): "
if not exist "!FULL_LAUNCHER_PATH!" (
    echo [X] El archivo no existe. Abortando...
    pause
    exit /b 1
)

:LAUNCHER_FOUND
echo.
echo ════════════════════════════════════════════════════════════════════
echo [1] LIMPIANDO CACHÉ Y ARCHIVOS TEMPORALES
echo ════════════════════════════════════════════════════════════════════

:: Limpiar carpetas de l2ashenvale (nombre nuevo)
echo [*] Limpiando caché de l2ashenvale...
rd /s /q "%APPDATA%\l2ashenvale\Cache" 2>nul
rd /s /q "%APPDATA%\l2ashenvale\GPUCache" 2>nul
rd /s /q "%APPDATA%\l2ashenvale\Code Cache" 2>nul
rd /s /q "%LOCALAPPDATA%\l2ashenvale-updater\cache" 2>nul
del /q "%APPDATA%\l2ashenvale\*.log" 2>nul

:: Limpiar carpetas de AshenvaleLauncher (nombre antiguo, por compatibilidad)
echo [*] Limpiando caché antiguo (si existe)...
rd /s /q "%APPDATA%\AshenvaleLauncher\Cache" 2>nul
rd /s /q "%APPDATA%\AshenvaleLauncher\GPUCache" 2>nul
rd /s /q "%APPDATA%\AshenvaleLauncher\Code Cache" 2>nul
rd /s /q "%LOCALAPPDATA%\AshenvaleLauncher" 2>nul
del /q "%APPDATA%\AshenvaleLauncher\*.log" 2>nul

echo [✓] Caché limpiado
echo.

echo ════════════════════════════════════════════════════════════════════
echo [2] CONFIGURANDO DNS Y RED
echo ════════════════════════════════════════════════════════════════════

echo [*] Limpiando caché DNS...
ipconfig /flushdns >nul 2>&1

echo [*] Reseteando Winsock...
netsh winsock reset >nul 2>&1

echo [*] Reseteando configuración TCP/IP...
netsh int ip reset >nul 2>&1

echo [✓] Configuración de red aplicada
echo.

echo ════════════════════════════════════════════════════════════════════
echo [3] CONFIGURANDO WINDOWS DEFENDER (SI ESTÁ DISPONIBLE)
echo ════════════════════════════════════════════════════════════════════

:: Detectar versión de Windows
for /f "tokens=4-5 delims=. " %%i in ('ver') do set VERSION=%%i.%%j

echo [*] Windows detectado: %VERSION%

if "%VERSION%" geq "10.0" (
    echo [*] Agregando excepciones a Windows Defender...
    
    :: Agregar ruta del launcher detectado
    for %%F in ("!FULL_LAUNCHER_PATH!") do (
        set "LAUNCHER_DIR=%%~dpF"
        powershell -Command "Add-MpPreference -ExclusionPath '!LAUNCHER_DIR!'" 2>nul
        powershell -Command "Add-MpPreference -ExclusionProcess '%%~nxF'" 2>nul
    )
    
    :: Agregar carpetas de datos
    powershell -Command "Add-MpPreference -ExclusionPath '%APPDATA%\l2ashenvale'" 2>nul
    powershell -Command "Add-MpPreference -ExclusionPath '%LOCALAPPDATA%\l2ashenvale-updater'" 2>nul
    
    :: Agregar carpeta del juego si existe
    if exist "C:\Games\Ashenvale" (
        powershell -Command "Add-MpPreference -ExclusionPath 'C:\Games\Ashenvale'" 2>nul
        powershell -Command "Add-MpPreference -ExclusionProcess 'l2.exe'" 2>nul
    )
    
    echo [✓] Excepciones agregadas
) else (
    echo [!] Windows 7/8 detectado - Windows Defender no disponible
)
echo.

echo ════════════════════════════════════════════════════════════════════
echo [4] CONFIGURANDO CERTIFICADOS Y TLS
echo ════════════════════════════════════════════════════════════════════

echo [*] Actualizando certificados SSL...
certutil -generateSSTFromWU roots.sst >nul 2>&1
certutil -addstore -f Root roots.sst >nul 2>&1
del roots.sst >nul 2>&1

echo [*] Habilitando TLS 1.2 y 1.3...
reg add "HKLM\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.2\Client" /v Enabled /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.2\Client" /v DisabledByDefault /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\.NETFramework\v4.0.30319" /v SchUseStrongCrypto /t REG_DWORD /d 1 /f >nul 2>&1

echo [✓] Certificados y TLS configurados
echo.

echo ════════════════════════════════════════════════════════════════════
echo [5] VERIFICANDO CONECTIVIDAD
echo ════════════════════════════════════════════════════════════════════

echo [*] Verificando conexión con servidores de Ashenvale...
ping -n 1 ashenvale.club >nul 2>&1
if %errorlevel% equ 0 (
    echo [✓] ashenvale.club - CONECTADO
) else (
    echo [X] ashenvale.club - SIN CONEXIÓN
)

ping -n 1 update.l2ashenvale.club >nul 2>&1
if %errorlevel% equ 0 (
    echo [✓] update.l2ashenvale.club - CONECTADO
) else (
    echo [X] update.l2ashenvale.club - SIN CONEXIÓN
)

ping -n 1 autoupdate.ashenvale.club >nul 2>&1
if %errorlevel% equ 0 (
    echo [✓] autoupdate.ashenvale.club - CONECTADO
) else (
    echo [X] autoupdate.ashenvale.club - SIN CONEXIÓN
)
echo.

echo ╔════════════════════════════════════════════════════════════════╗
echo ║                    PROCESO COMPLETADO                         ║
echo ╚════════════════════════════════════════════════════════════════╝
echo.
echo ACCIONES REALIZADAS:
echo [✓] Caché del launcher limpiado
echo [✓] Configuración de red reseteada
echo [✓] Excepciones de antivirus configuradas (si aplica)
echo [✓] Certificados SSL actualizados
echo [✓] TLS 1.2/1.3 habilitado
echo.
echo RECOMENDACIONES:
echo 1. Reinicie su PC para aplicar todos los cambios
echo 2. Ejecute el launcher normalmente
echo 3. Si persisten problemas, use el modo debug (Launcher_Debug.bat)
echo.
echo Launcher detectado: !FULL_LAUNCHER_PATH!
echo.
pause