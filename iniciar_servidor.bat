@echo off
setlocal
title Servidor de Asistencia SENA
cd /d "%~dp0"

:: Modo por defecto: HTTPS (necesario para la camara en vivo del celular).
:: Usa "iniciar_servidor.bat --http" para forzar HTTP simple.
set "MODE=--https"
set "URL=https://192.168.20.21:5000"
if /I "%~1"=="--http" (
  set "MODE="
  set "URL=http://192.168.20.21:5000"
)

echo ======================================================================
echo           SERVIDOR DE CONTROL DE ASISTENCIA SENA
echo ======================================================================
echo.
echo   En este PC    : %URL%   (o https://localhost:5000)
echo   En el CELULAR : %URL%
echo.
echo   IMPORTANTE: en el celular escribe EXACTAMENTE ese enlace
echo               (respeta http:// o https:// segun se muestre arriba).
echo.
echo   Para detener el servidor: Ctrl+C o cierra esta ventana.
echo ======================================================================
echo.

if /I "%MODE%"=="--https" (
  if not exist cert.pem goto :nocert
  if not exist key.pem goto :nocert
)

python app.py %MODE%
echo.
echo [Servidor detenido]
pause
exit /b 0

:nocert
echo [ERROR] No se encontraron cert.pem / key.pem en esta carpeta.
echo.
echo   Ejecuta primero:   generar_certificados.bat
echo   (o arranca en HTTP con:  iniciar_servidor.bat --http)
echo.
pause
exit /b 1
