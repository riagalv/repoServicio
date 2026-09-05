@echo off
title Servidor de Registro de Ordenes
cd /d "%~dp0"

set "PATH=%PATH%;C:\Program Files\nodejs;%LOCALAPPDATA%\Programs\nodejs;%APPDATA%\npm"

echo ========================================================
echo   SERVIDOR DE REGISTRO DE ORDENES - BACKEND
echo ========================================================
echo.

where node >nul 2>nul
if %errorlevel% neq 0 (
    echo [ERROR] No se encontro Node.js en esta computadora.
    echo Por favor instala Node.js desde https://nodejs.org/
    echo.
    pause
    goto fin
)

if not exist "node_modules\express" (
    echo [INFO] Descargando librerias necesarias...
    call npm install express cors --no-audit --no-fund
    if %errorlevel% neq 0 (
        echo [ERROR] Ocurrio un problema al descargar las librerias.
        echo.
        pause
        goto fin
    )
)

echo.
echo [OK] Iniciando el servidor backend...
echo Presiona Ctrl + C para detener el servidor.
echo.
echo ========================================================
echo.

node server.js

echo.
echo [AVISO] El servidor se ha detenido.
echo.
pause

:fin
