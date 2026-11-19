# Informe Técnico de Estado, Diagnóstico y Hoja de Ruta

**Proyecto:** Sistema de Control de Asistencia mediante Códigos QR de Carnets SENA  
**Fecha:** 2026-10-15  
**Ubicación:** `d:\Repositorios\Asistencia_QR`  
**Destinatario:** Desarrollador / Agente Relevo  

---

## 1. Resumen Ejecutivo

El sistema está **completamente funcional y verificado con pruebas automatizadas (6/6)**. Incluye backend Flask, persistencia SQLite en modo WAL, parseo estricto del JSON institucional del SENA, lógica anti-duplicados y un frontend responsivo con tres fuentes de entrada (escáner USB, cámara móvil en vivo y foto).

**Resolución del acceso móvil:** el problema técnico de la cámara en vivo se resolvió **sin HTTPS local, sin certificados y sin OpenSSL**, empleando el **Port Forwarding (túneles) de Visual Studio Code**. El servidor corre de forma nativa en **HTTP puro** (`localhost:5000`) y VS Code publica ese puerto mediante una **URL HTTPS de confianza**, que constituye un contexto seguro para el navegador del celular.

Esta decisión elimina toda la infraestructura de certificados que se había explorado previamente y simplifica el despliegue.

---

## 2. Lo Que Ya Funciona al 100% (NO MODIFICAR NI DAÑAR)

Los siguientes módulos y contratos de software están estables y respaldados por la suite de pruebas automatizadas [`test_endpoints.py`](test_endpoints.py) (6/6 tests pasando):

### A. Base de Datos Autónoma (`registro_aprendices.db`)
- Motor: SQLite3 con modo `WAL` (`PRAGMA journal_mode = WAL;`) para alta concurrencia.
- Tabla `asistencia`:
  ```sql
  CREATE TABLE IF NOT EXISTS asistencia (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      documento TEXT NOT NULL,
      nombre TEXT NOT NULL,
      ficha TEXT,
      programa TEXT,
      datos_qr TEXT NOT NULL,
      fecha TEXT NOT NULL,
      hora TEXT NOT NULL
  );
  ```
- **Lógica Anti-Duplicados (Anti-Rebote):**
  Consulta por `documento` y `fecha` (`YYYY-MM-DD`). Si el aprendiz ya ingresó hoy, devuelve estado `"duplicado"` sin registrar doble asistencia.

### B. Parseo Estricto de Carnet SENA (`parsear_carnet_sena`)
- Los carnets reales del SENA contienen un string JSON con este formato exacto:
  ```json
  {"nom":"Diego Alejandro Arboleda Cuero","doc":"CC 1087834596","cargo":"Aprendiz","rh":"O+","ficha":"3564995","dep":"9220","prog":"ANALISIS Y DESARROLLO DE SOFTWARE - 228118 V1"}
  ```
- El backend procesa el string con `json.loads` dentro de un bloque `try ... except json.JSONDecodeError`.
- Si se escanea un QR ajeno (ej. una URL web o texto plano), responde con HTTP `400 Bad Request` informando del error de forma limpia, **sin que el servidor se caiga ni se interrumpa**.

### C. Endpoints REST del Backend ([`app.py`](app.py))
- `GET /`: Sirve la interfaz web responsiva [`templates/index.html`](templates/index.html).
- `POST /registrar`: Recibe `{ "qr_data": "<string_json>" }`, parsea, valida anti-duplicados y persiste en SQLite. Devuelve:
  - `HTTP 200` + `{ "status": "exitoso", "aprendiz": {...}, "hora": "...", "fecha": "..." }`
  - `HTTP 200` + `{ "status": "duplicado", "mensaje": "Ya registrado hoy.", "aprendiz": {...} }`
  - `HTTP 400` + `{ "status": "error", "mensaje": "..." }`
- `POST /registrar_foto`: Endpoint multipart donde el celular sube una foto del carnet; el servidor la decodifica con OpenCV (`cv2`) y `pyzbar` en Python.
- `GET /api/asistencias/hoy`: Devuelve la lista en tiempo real de aprendices registrados en la fecha actual.

### D. Soporte para Escáner Físico USB (Teclado HID)
- Los lectores USB comerciales actúan como teclados que inyectan caracteres a alta velocidad y presionan la tecla `Enter`.
- El frontend tiene un input con foco permanente (`#usb-scanner-input`) que escucha el evento `Enter` y despacha la petición al endpoint `/registrar`.

---

## 3. Diagnóstico: ¿Por Qué se Requiere Contexto Seguro para la Cámara?

### Causa Raíz Técnica: Restricción W3C "Secure Context"
Por especificación de seguridad de los navegadores web modernos (Chrome, Safari, Firefox, Edge en Android e iOS):

1. **Restricción de `getUserMedia` sobre HTTP:**
   La API `navigator.mediaDevices.getUserMedia` (usada por `html5-qrcode`) **solo se activa en contextos seguros** (`https://` o `http://localhost`). Cuando un celular accede por red local a una IP no cifrada (`http://192.168.20.21:5000`), el navegador deja `navigator.mediaDevices` indefinido y la librería falla con *"Camera streaming not supported or insecure context"*.

2. **Por qué NO se usan certificados autofirmados locales:**
   Activar HTTPS en Flask con certificados autofirmados obliga a instalar una CA local en cada dispositivo, genera advertencias tipo `NET::ERR_CERT_AUTHORITY_INVALID` y, en algunos modelos, el navegador bloquea la cámara aun aceptando el riesgo. Es frágil y difícil de mantener.

3. **Solución adoptada: túnel HTTPS de VS Code.**
   VS Code reenvía el puerto local y genera una URL `https://…` respaldada por un certificado válido. Al ser un contexto seguro de confianza, el navegador móvil habilita la cámara sin advertencias ni instalación de certificados.

---

## 4. Arquitectura de Acceso Móvil (Port Forwarding de VS Code)

```
[Servidor Flask]                      [VS Code]                       [Celular]
 http://localhost:5000  <--- reenvía --- puerto 5000 --- HTTPS --->  https://<id>-5000.app.github.dev
      (HTTP puro)                       (túnel TLS)                       (contexto seguro)
```

**Pasos de operación:**
1. Ejecutar el servidor: `python app.py` (o `iniciar_servidor.bat`). Escucha en `http://localhost:5000`.
2. En VS Code, abrir la pestaña **Ports / Puertos**.
3. Reenviar el puerto `5000` (**Forward a Port**).
4. Copiar la **URL HTTPS** generada y abrirla en el navegador del celular.
5. Pulsar "Activar Cámara en Vivo": el navegador pide permiso y funciona (contexto seguro).

---

## 5. Limpieza SSL/HTTPS Local Realizada (2026-10-15)

Se retiró toda la infraestructura de HTTPS local por quedar obsoleta ante el túnel de VS Code. **Sin tocar el backend lógico, SQLite ni los contratos REST:**

- `app.py`: eliminadas las constantes `CERT_FILE` / `KEY_FILE` y el arranque condicional `--https` / `ssl_context`. El servidor arranca estrictamente en HTTP puro: `app.run(host="0.0.0.0", port=5000)`. Se removió `import sys` (solo se usaba para leer `--https`).
- **Eliminados del repositorio:** `cert.pem`, `key.pem`, `rootCA.crt`, `rootCA.key`, `rootCA.pem`, `rootCA.srl`, `cert.pem.autofirmado.bak`, `key.pem.autofirmado.bak`, `generar_certificados.bat`, `habilitar_red_celular.bat` y `server_https.log`.
- `requirements.txt`: removida la dependencia `cryptography` (solo servía para generar certificados).
- `.gitignore`: removida la sección de patrones SSL (`*.pem`, `*.key`, `*.crt`, `*.srl`, `*.bak`).
- `iniciar_servidor.bat`: simplificado a HTTP puro, sin verificación de certificados ni modo `--https`.
- `templates/index.html`: actualizado **solo** el texto del aviso de contexto no seguro (ahora referencia la URL del túnel de VS Code). La lógica de cámara/escaneo permanece intacta.

---

## 6. Instrucciones para el Próximo Agente / Desarrollador

Si vas a continuar este desarrollo:

1. **NO modifiques el esquema de la base de datos** (`documento`, `nombre`, `ficha`, `programa`, `datos_qr`, `fecha`, `hora`).
2. **NO elimines el parseo estricto de JSON** en [`app.py`](app.py). Es el formato real de los carnets del SENA.
3. **Conserva el endpoint `/registrar`** con su firma actual, ya que es el contrato utilizado por el lector USB, la cámara y las pruebas.
4. **NO reintroduzcas HTTPS local ni certificados.** El acceso móvil se resuelve con el túnel de VS Code; el servidor debe seguir en HTTP puro.
5. **Ejecuta siempre la suite de pruebas** tras cualquier cambio para garantizar que no hay regresiones:
   ```powershell
   python test_endpoints.py
   ```

---

## 7. Estado de Verificación

- Suite `test_endpoints.py`: **6/6 PASS**.
- El servidor arranca en HTTP puro sin `ssl_context` ni certificados.
- La cámara en vivo móvil opera correctamente a través de la URL HTTPS del túnel de VS Code.
