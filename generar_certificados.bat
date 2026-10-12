@echo off
setlocal
cd /d "%~dp0"

:: IP del servidor. Se puede pasar como primer argumento: generar_certificados.bat 192.168.1.50
set "IP=192.168.20.21"
if not "%~1"=="" set "IP=%~1"

echo ======================================================================
echo   GENERADOR DE CERTIFICADOS LOCALES (CA + Servidor) - Asistencia SENA
echo   IP / host del servidor: %IP%
echo ======================================================================
echo.

where openssl >nul 2>&1
if errorlevel 1 (
  echo [ERROR] No se encontro 'openssl' en el PATH.
  echo Instala Git for Windows o agregalo al PATH y vuelve a intentar.
  pause
  exit /b 1
)

if exist rootCA.pem if exist rootCA.key goto :have_ca

echo [1/4] Generando Autoridad Certificadora local (CA) nueva...
openssl req -x509 -newkey rsa:2048 -nodes -keyout rootCA.key -out rootCA.pem -days 3650 ^
  -subj "/O=SENA Asistencia/CN=Asistencia SENA CA" ^
  -addext "basicConstraints=critical,CA:TRUE" ^
  -addext "keyUsage=critical,keyCertSign,cRLSign"
if errorlevel 1 goto :err
goto :gen_server

:have_ca
echo [1/4] CA local ya existente: se reutiliza (rootCA.pem / rootCA.key).
echo       El celular NO necesita reinstalar la CA.

:gen_server
echo [2/4] Generando llave privada y CSR del servidor (IP %IP%)...
openssl req -newkey rsa:2048 -nodes -keyout key.pem -out server.csr ^
  -subj "/O=SENA Asistencia/CN=%IP%"
if errorlevel 1 goto :err

echo [3/4] Firmando el certificado del servidor con la CA...
> server_ext.cnf echo basicConstraints=CA:FALSE
>> server_ext.cnf echo keyUsage=critical,digitalSignature,keyEncipherment
>> server_ext.cnf echo extendedKeyUsage=serverAuth
>> server_ext.cnf echo subjectAltName=IP:%IP%,DNS:localhost
openssl x509 -req -in server.csr -CA rootCA.pem -CAkey rootCA.key -CAcreateserial ^
  -out server.crt -days 825 -sha256 -extfile server_ext.cnf
if errorlevel 1 goto :err

echo [4/4] Construyendo cadena cert.pem y copia rootCA.crt para el celular...
copy /y /b server.crt+rootCA.pem cert.pem >nul
copy /y /b rootCA.pem rootCA.crt >nul
del server.csr server_ext.cnf server.crt 2>nul

echo.
echo ======================================================================
echo   LISTO. Archivos generados:
echo     - rootCA.crt  ==^> INSTALAR en cada celular (Certificado de CA)
echo     - cert.pem / key.pem  ==^> los consume app.py  (python app.py --https)
echo ======================================================================
echo.
pause
exit /b 0

:err
echo.
echo [ERROR] Fallo la generacion de certificados. Revisa que openssl funcione.
pause
exit /b 1
