@echo off
setlocal EnableDelayedExpansion
chcp 65001 >nul 2>&1
title Ashenvale - Diagnóstico del Sistema v3.0

:: Configurar tamaño de ventana (120 columnas x 50 líneas)
mode con: cols=120 lines=50

:: Crear archivo de diagnóstico con timestamp
for /f "tokens=2 delims==" %%a in ('wmic OS Get localdatetime /value') do set "dt=%%a"
set "timestamp=%dt:~0,4%-%dt:~4,2%-%dt:~6,2%_%dt:~8,2%-%dt:~10,2%-%dt:~12,2%"
set "DIAGNOSTIC_FILE=Diagnostico_Ashenvale_%timestamp%.txt"

echo.
echo ╔════════════════════════════════════════════════════════════════╗
echo ║     ASHENVALE - DIAGNÓSTICO DEL SISTEMA v3.0                  ║
echo ║     Generando informe completo...                             ║
echo ╚════════════════════════════════════════════════════════════════╝
echo.

:: Iniciar archivo de diagnóstico
echo ======================================== > "%DIAGNOSTIC_FILE%"
echo DIAGNÓSTICO ASHENVALE LAUNCHER >> "%DIAGNOSTIC_FILE%"
echo Fecha: %date% %time% >> "%DIAGNOSTIC_FILE%"
echo ======================================== >> "%DIAGNOSTIC_FILE%"
echo. >> "%DIAGNOSTIC_FILE%"

echo [*] Detectando launcher instalado...
echo DETECCIÓN DEL LAUNCHER >> "%DIAGNOSTIC_FILE%"
echo ---------------------------------------- >> "%DIAGNOSTIC_FILE%"

:: Buscar en registro
set "LAUNCHER_FOUND=NO"
set "LAUNCHER_PATH="
set "LAUNCHER_NAME="

:: HKLM
for /f "tokens=2*" %%a in ('reg query "HKLM\Software\Ashenvale\InstallLocation" /v "ManagerPath" 2^>nul ^| find "ManagerPath"') do (
    set "LAUNCHER_PATH=%%b"
    echo Registro HKLM - Path: %%b >> "%DIAGNOSTIC_FILE%"
)
for /f "tokens=2*" %%a in ('reg query "HKLM\Software\Ashenvale\InstallLocation" /v "ManagerName" 2^>nul ^| find "ManagerName"') do (
    set "LAUNCHER_NAME=%%b"
    echo Registro HKLM - Name: %%b >> "%DIAGNOSTIC_FILE%"
)

:: HKCU
if not defined LAUNCHER_PATH (
    for /f "tokens=2*" %%a in ('reg query "HKCU\Software\Ashenvale\InstallLocation" /v "ManagerPath" 2^>nul ^| find "ManagerPath"') do (
        set "LAUNCHER_PATH=%%b"
        echo Registro HKCU - Path: %%b >> "%DIAGNOSTIC_FILE%"
    )
    for /f "tokens=2*" %%a in ('reg query "HKCU\Software\Ashenvale\InstallLocation" /v "ManagerName" 2^>nul ^| find "ManagerName"') do (
        set "LAUNCHER_NAME=%%b"
        echo Registro HKCU - Name: %%b >> "%DIAGNOSTIC_FILE%"
    )
)

if defined LAUNCHER_PATH (
    if defined LAUNCHER_NAME (
        if exist "%LAUNCHER_PATH%\%LAUNCHER_NAME%" (
            echo [✓] Launcher detectado en registro
            echo Launcher en registro: %LAUNCHER_PATH%\%LAUNCHER_NAME% [EXISTE] >> "%DIAGNOSTIC_FILE%"
            set "LAUNCHER_FOUND=SI"
        ) else (
            echo [!] Registro encontrado pero archivo no existe
            echo Launcher en registro: %LAUNCHER_PATH%\%LAUNCHER_NAME% [NO EXISTE] >> "%DIAGNOSTIC_FILE%"
        )
    )
) else (
    echo No se encontró información en el registro >> "%DIAGNOSTIC_FILE%"
)

echo. >> "%DIAGNOSTIC_FILE%"
echo Búsqueda en rutas conocidas: >> "%DIAGNOSTIC_FILE%"

:: Buscar en rutas conocidas
if exist "%PROGRAMFILES%\AshenvaleLauncher\AshenvaleLauncher.exe" (
    echo - %PROGRAMFILES%\AshenvaleLauncher\AshenvaleLauncher.exe [ENCONTRADO] >> "%DIAGNOSTIC_FILE%"
    set "LAUNCHER_FOUND=SI"
) else (
    echo - %PROGRAMFILES%\AshenvaleLauncher\AshenvaleLauncher.exe [NO ENCONTRADO] >> "%DIAGNOSTIC_FILE%"
)

if exist "%LOCALAPPDATA%\Programs\AshenvaleLauncher\AshenvaleLauncher.exe" (
    echo - %LOCALAPPDATA%\Programs\AshenvaleLauncher\AshenvaleLauncher.exe [ENCONTRADO] >> "%DIAGNOSTIC_FILE%"
    set "LAUNCHER_FOUND=SI"
) else (
    echo - %LOCALAPPDATA%\Programs\AshenvaleLauncher\AshenvaleLauncher.exe [NO ENCONTRADO] >> "%DIAGNOSTIC_FILE%"
)

if exist "%PROGRAMFILES%\l2ashenvale\l2ashenvale.exe" (
    echo - %PROGRAMFILES%\l2ashenvale\l2ashenvale.exe [ENCONTRADO] >> "%DIAGNOSTIC_FILE%"
    set "LAUNCHER_FOUND=SI"
) else (
    echo - %PROGRAMFILES%\l2ashenvale\l2ashenvale.exe [NO ENCONTRADO] >> "%DIAGNOSTIC_FILE%"
)

if exist "%LOCALAPPDATA%\Programs\l2ashenvale\l2ashenvale.exe" (
    echo - %LOCALAPPDATA%\Programs\l2ashenvale\l2ashenvale.exe [ENCONTRADO] >> "%DIAGNOSTIC_FILE%"
    set "LAUNCHER_FOUND=SI"
) else (
    echo - %LOCALAPPDATA%\Programs\l2ashenvale\l2ashenvale.exe [NO ENCONTRADO] >> "%DIAGNOSTIC_FILE%"
)

echo. >> "%DIAGNOSTIC_FILE%"

echo [*] Verificando sistema operativo...
echo INFORMACIÓN DEL SISTEMA >> "%DIAGNOSTIC_FILE%"
echo ---------------------------------------- >> "%DIAGNOSTIC_FILE%"

:: Sistema operativo
for /f "tokens=4-5 delims=. " %%i in ('ver') do set VERSION=%%i.%%j
echo Versión de Windows: %VERSION% >> "%DIAGNOSTIC_FILE%"

wmic os get Caption,Version,OSArchitecture /value | findstr "=" >> "%DIAGNOSTIC_FILE%"
echo. >> "%DIAGNOSTIC_FILE%"

echo [*] Verificando .NET Framework...
echo .NET FRAMEWORK >> "%DIAGNOSTIC_FILE%"
echo ---------------------------------------- >> "%DIAGNOSTIC_FILE%"

:: .NET Framework
reg query "HKLM\SOFTWARE\Microsoft\NET Framework Setup\NDP\v4\Full" /v Release 2>nul | find "Release" >> "%DIAGNOSTIC_FILE%"
if %errorlevel% equ 0 (
    echo [✓] .NET Framework 4.x detectado
    for /f "tokens=3" %%a in ('reg query "HKLM\SOFTWARE\Microsoft\NET Framework Setup\NDP\v4\Full" /v Release 2^>nul ^| find "Release"') do (
        set /a netver=%%a
        if !netver! geq 528040 echo Version: 4.8 o superior >> "%DIAGNOSTIC_FILE%"
        if !netver! lss 528040 if !netver! geq 461808 echo Version: 4.7.2 >> "%DIAGNOSTIC_FILE%"
        if !netver! lss 461808 echo Version: Anterior a 4.7.2 [ACTUALIZAR RECOMENDADO] >> "%DIAGNOSTIC_FILE%"
    )
) else (
    echo [X] .NET Framework 4.x NO detectado
    echo .NET Framework 4.x: NO INSTALADO >> "%DIAGNOSTIC_FILE%"
)
echo. >> "%DIAGNOSTIC_FILE%"

echo [*] Verificando Visual C++ Redistributables...
echo VISUAL C++ REDISTRIBUTABLES >> "%DIAGNOSTIC_FILE%"
echo ---------------------------------------- >> "%DIAGNOSTIC_FILE%"

:: Visual C++ 2015-2022
reg query "HKLM\SOFTWARE\Microsoft\VisualStudio\14.0\VC\Runtimes\x64" /v Version 2>nul | find "Version" >nul
if %errorlevel% equ 0 (
    echo [✓] Visual C++ 2015-2022 x64 detectado
    echo Visual C++ 2015-2022 x64: INSTALADO >> "%DIAGNOSTIC_FILE%"
) else (
    echo [X] Visual C++ 2015-2022 x64 NO detectado
    echo Visual C++ 2015-2022 x64: NO INSTALADO >> "%DIAGNOSTIC_FILE%"
)

reg query "HKLM\SOFTWARE\WOW6432Node\Microsoft\VisualStudio\14.0\VC\Runtimes\x86" /v Version 2>nul | find "Version" >nul
if %errorlevel% equ 0 (
    echo [✓] Visual C++ 2015-2022 x86 detectado
    echo Visual C++ 2015-2022 x86: INSTALADO >> "%DIAGNOSTIC_FILE%"
) else (
    echo [X] Visual C++ 2015-2022 x86 NO detectado
    echo Visual C++ 2015-2022 x86: NO INSTALADO >> "%DIAGNOSTIC_FILE%"
)
echo. >> "%DIAGNOSTIC_FILE%"

echo [*] Verificando Edge WebView2...
echo EDGE WEBVIEW2 RUNTIME >> "%DIAGNOSTIC_FILE%"
echo ---------------------------------------- >> "%DIAGNOSTIC_FILE%"

:: Edge WebView2
reg query "HKLM\SOFTWARE\WOW6432Node\Microsoft\EdgeUpdate\Clients\{F3017226-FE2A-4295-8BDF-00C3A9A7E4C5}" /v pv 2>nul | find "pv" >nul
if %errorlevel% equ 0 (
    echo [✓] Edge WebView2 Runtime detectado
    echo Edge WebView2 Runtime: INSTALADO >> "%DIAGNOSTIC_FILE%"
    reg query "HKLM\SOFTWARE\WOW6432Node\Microsoft\EdgeUpdate\Clients\{F3017226-FE2A-4295-8BDF-00C3A9A7E4C5}" /v pv 2>nul | find "pv" >> "%DIAGNOSTIC_FILE%"
) else (
    echo [X] Edge WebView2 Runtime NO detectado - CRÍTICO
    echo Edge WebView2 Runtime: NO INSTALADO [CRÍTICO PARA EL LAUNCHER] >> "%DIAGNOSTIC_FILE%"
)
echo. >> "%DIAGNOSTIC_FILE%"

echo [*] Verificando DirectX...
echo DIRECTX >> "%DIAGNOSTIC_FILE%"
echo ---------------------------------------- >> "%DIAGNOSTIC_FILE%"

:: DirectX
dxdiag /x dxtemp.xml >nul 2>&1
timeout /t 2 >nul
if exist dxtemp.xml (
    for /f "tokens=2 delims=<>" %%a in ('findstr /i "DirectXVersion" dxtemp.xml 2^>nul') do (
        echo DirectX Version: %%a >> "%DIAGNOSTIC_FILE%"
        echo [✓] DirectX detectado: %%a
    )
    del dxtemp.xml >nul 2>&1
) else (
    echo No se pudo determinar la versión de DirectX >> "%DIAGNOSTIC_FILE%"
)
echo. >> "%DIAGNOSTIC_FILE%"

echo [*] Verificando carpetas de caché...
echo CARPETAS DE DATOS DEL LAUNCHER >> "%DIAGNOSTIC_FILE%"
echo ---------------------------------------- >> "%DIAGNOSTIC_FILE%"

:: Carpetas de l2ashenvale
if exist "%APPDATA%\l2ashenvale" (
    echo %APPDATA%\l2ashenvale [EXISTE] >> "%DIAGNOSTIC_FILE%"
    dir "%APPDATA%\l2ashenvale" /s 2>nul | find "File(s)" >> "%DIAGNOSTIC_FILE%"
) else (
    echo %APPDATA%\l2ashenvale [NO EXISTE] >> "%DIAGNOSTIC_FILE%"
)

if exist "%LOCALAPPDATA%\l2ashenvale-updater" (
    echo %LOCALAPPDATA%\l2ashenvale-updater [EXISTE] >> "%DIAGNOSTIC_FILE%"
    dir "%LOCALAPPDATA%\l2ashenvale-updater" /s 2>nul | find "File(s)" >> "%DIAGNOSTIC_FILE%"
) else (
    echo %LOCALAPPDATA%\l2ashenvale-updater [NO EXISTE] >> "%DIAGNOSTIC_FILE%"
)

:: Carpetas antiguas
if exist "%APPDATA%\AshenvaleLauncher" (
    echo %APPDATA%\AshenvaleLauncher [EXISTE - VERSIÓN ANTIGUA] >> "%DIAGNOSTIC_FILE%"
)
if exist "%LOCALAPPDATA%\AshenvaleLauncher" (
    echo %LOCALAPPDATA%\AshenvaleLauncher [EXISTE - VERSIÓN ANTIGUA] >> "%DIAGNOSTIC_FILE%"
)
echo. >> "%DIAGNOSTIC_FILE%"

echo [*] Buscando configuración del cliente L2...
echo CLIENTE DEL JUEGO (L2) >> "%DIAGNOSTIC_FILE%"
echo ---------------------------------------- >> "%DIAGNOSTIC_FILE%"

:: Buscar en archivos de configuración del launcher
set "L2_PATH="
set "CONFIG_FOUND=NO"

:: Buscar en config.json de l2ashenvale
if exist "%APPDATA%\l2ashenvale\config.json" (
    echo Archivo config encontrado: %APPDATA%\l2ashenvale\config.json >> "%DIAGNOSTIC_FILE%"
    for /f "tokens=*" %%a in ('type "%APPDATA%\l2ashenvale\config.json" 2^>nul ^| findstr /i "gamePath"') do (
        echo Config del launcher: %%a >> "%DIAGNOSTIC_FILE%"
        set "CONFIG_FOUND=SI"
    )
)

:: Buscar en AshenvaleLauncher (versión antigua)
if exist "%APPDATA%\AshenvaleLauncher\config.json" (
    echo Archivo config encontrado: %APPDATA%\AshenvaleLauncher\config.json >> "%DIAGNOSTIC_FILE%"
    for /f "tokens=*" %%a in ('type "%APPDATA%\AshenvaleLauncher\config.json" 2^>nul ^| findstr /i "gamePath"') do (
        echo Config del launcher: %%a >> "%DIAGNOSTIC_FILE%"
        set "CONFIG_FOUND=SI"
    )
)

:: Buscar L2.exe en rutas comunes
echo. >> "%DIAGNOSTIC_FILE%"
echo Búsqueda de L2.exe en rutas comunes: >> "%DIAGNOSTIC_FILE%"
set "L2_FOUND=NO"
for %%D in (C: D: E: F: G:) do (
    if exist "%%D\Games\Ashenvale\L2.exe" (
        echo - %%D\Games\Ashenvale\L2.exe [ENCONTRADO] >> "%DIAGNOSTIC_FILE%"
        set "L2_FOUND=SI"
    )
    if exist "%%D\Ashenvale\L2.exe" (
        echo - %%D\Ashenvale\L2.exe [ENCONTRADO] >> "%DIAGNOSTIC_FILE%"
        set "L2_FOUND=SI"
    )
    if exist "%%D\L2Ashenvale\L2.exe" (
        echo - %%D\L2Ashenvale\L2.exe [ENCONTRADO] >> "%DIAGNOSTIC_FILE%"
        set "L2_FOUND=SI"
    )
)

if "%L2_FOUND%"=="NO" (
    echo No se encontró L2.exe en rutas comunes >> "%DIAGNOSTIC_FILE%"
    echo NOTA: El cliente puede estar instalado en otra ubicación >> "%DIAGNOSTIC_FILE%"
)
echo. >> "%DIAGNOSTIC_FILE%"

echo [*] Verificando conectividad...
echo CONECTIVIDAD DE RED >> "%DIAGNOSTIC_FILE%"
echo ---------------------------------------- >> "%DIAGNOSTIC_FILE%"

:: Pruebas de ping
ping -n 1 ashenvale.club >nul 2>&1
if %errorlevel% equ 0 (
    echo [✓] ashenvale.club - CONECTADO
    echo ashenvale.club: CONECTADO >> "%DIAGNOSTIC_FILE%"
) else (
    echo [X] ashenvale.club - SIN CONEXIÓN
    echo ashenvale.club: SIN CONEXIÓN >> "%DIAGNOSTIC_FILE%"
)

ping -n 1 update.l2ashenvale.club >nul 2>&1
if %errorlevel% equ 0 (
    echo [✓] update.l2ashenvale.club - CONECTADO
    echo update.l2ashenvale.club: CONECTADO >> "%DIAGNOSTIC_FILE%"
) else (
    echo [X] update.l2ashenvale.club - SIN CONEXIÓN
    echo update.l2ashenvale.club: SIN CONEXIÓN >> "%DIAGNOSTIC_FILE%"
)

ping -n 1 autoupdate.ashenvale.club >nul 2>&1
if %errorlevel% equ 0 (
    echo [✓] autoupdate.ashenvale.club - CONECTADO
    echo autoupdate.ashenvale.club: CONECTADO >> "%DIAGNOSTIC_FILE%"
) else (
    echo [X] autoupdate.ashenvale.club - SIN CONEXIÓN
    echo autoupdate.ashenvale.club: SIN CONEXIÓN >> "%DIAGNOSTIC_FILE%"
)
echo. >> "%DIAGNOSTIC_FILE%"

echo [*] Verificando Windows Defender...
echo WINDOWS DEFENDER >> "%DIAGNOSTIC_FILE%"
echo ---------------------------------------- >> "%DIAGNOSTIC_FILE%"

:: Windows Defender (solo Windows 10/11)
if "%VERSION%" geq "10.0" (
    powershell -Command "Get-MpPreference | Select-Object -ExpandProperty ExclusionPath" 2>nul >> "%DIAGNOSTIC_FILE%"
    powershell -Command "Get-MpPreference | Select-Object -ExpandProperty ExclusionProcess" 2>nul >> "%DIAGNOSTIC_FILE%"
) else (
    echo Windows Defender no disponible en esta versión >> "%DIAGNOSTIC_FILE%"
)
echo. >> "%DIAGNOSTIC_FILE%"

echo [*] Verificando configuración de firewall...
echo FIREWALL Y ANTIVIRUS >> "%DIAGNOSTIC_FILE%"
echo ---------------------------------------- >> "%DIAGNOSTIC_FILE%"

:: Verificar si el launcher está en las reglas del firewall
set "FIREWALL_OK=NO"
for /f "tokens=*" %%a in ('netsh advfirewall firewall show rule name=all 2^>nul ^| findstr /i "AshenvaleLauncher l2ashenvale"') do (
    set "FIREWALL_OK=SI"
)

if "%FIREWALL_OK%"=="SI" (
    echo Launcher configurado en Windows Firewall: SI >> "%DIAGNOSTIC_FILE%"
) else (
    echo Launcher configurado en Windows Firewall: NO [PUEDE CAUSAR PROBLEMAS] >> "%DIAGNOSTIC_FILE%"
)

:: Info sobre los puertos del servidor (no del cliente)
echo. >> "%DIAGNOSTIC_FILE%"
echo INFORMACIÓN DE CONEXIÓN: >> "%DIAGNOSTIC_FILE%"
echo - El cliente se conecta al servidor en puerto 7777 (Game Server) >> "%DIAGNOSTIC_FILE%"
echo - El cliente se conecta al servidor en puerto 2106 (Login Server) >> "%DIAGNOSTIC_FILE%"
echo - Las actualizaciones usan puertos 80/443 (HTTP/HTTPS) >> "%DIAGNOSTIC_FILE%"
echo - Estos puertos son del SERVIDOR, no necesitan estar abiertos en el cliente >> "%DIAGNOSTIC_FILE%"
echo. >> "%DIAGNOSTIC_FILE%"

echo ======================================== >> "%DIAGNOSTIC_FILE%"
echo FIN DEL DIAGNÓSTICO >> "%DIAGNOSTIC_FILE%"
echo ======================================== >> "%DIAGNOSTIC_FILE%"

echo.
echo ╔════════════════════════════════════════════════════════════════╗
echo ║                 DIAGNÓSTICO COMPLETADO                        ║
echo ╚════════════════════════════════════════════════════════════════╝
echo.
echo Archivo generado: %DIAGNOSTIC_FILE%
echo.
echo RESUMEN:
if "%LAUNCHER_FOUND%"=="SI" (
    echo [✓] Launcher detectado
) else (
    echo [X] Launcher NO detectado - Instale o verifique la instalación
)

:: Verificar si se encontró el cliente L2
if "%L2_FOUND%"=="SI" (
    echo [✓] Cliente L2 detectado
) else (
    echo [!] Cliente L2 no encontrado en rutas comunes
)

echo.
echo El archivo contiene información detallada sobre:
echo - Ubicación del launcher y su configuración
echo - Ubicación del cliente L2 (si está configurado)
echo - Componentes instalados (.NET, Visual C++, WebView2, DirectX)
echo - Estado de conectividad con servidores
echo - Configuración de Windows Defender y Firewall
echo.
echo Comparta este archivo con soporte técnico si necesita ayuda.
echo.
pause