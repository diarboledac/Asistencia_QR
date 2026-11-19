@echo off
setlocal
title Servidor de Asistencia SENA
cd /d "%~dp0"

echo ======================================================================
echo           SERVIDOR DE CONTROL DE ASISTENCIA SENA
echo ======================================================================
echo.
echo   En este PC    : http://localhost:5000
echo.
echo   Para usarlo desde el CELULAR:
echo     1. Deja esta ventana abierta (el servidor ya esta en HTTP local).
echo     2. En VS Code abre la pestana "Ports / Puertos".
echo     3. Reenvia el puerto 5000  (Forward a Port -^> 5000).
echo     4. Copia la URL HTTPS que genera VS Code y abrela en el celular.
echo.
echo   Para detener el servidor: Ctrl+C o cierra esta ventana.
echo ======================================================================
echo.

python app.py
echo.
echo [Servidor detenido]
pause
exit /b 0
