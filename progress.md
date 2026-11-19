# Progress - Sistema de Control de Asistencia QR SENA

## Estado Actual
- **Fase**: Arquitectura final estable. Acceso móvil resuelto con túnel HTTPS de VS Code (sin SSL local).
- **Fecha**: 2026-10-15
- **Repositorio**: `d:\Repositorios\Asistencia_QR`

## Tareas Completadas
- [x] **Backend REST**: Construido con Flask (`app.py`), endpoints `/`, `/registrar`, `/registrar_foto`, `/api/asistencias/hoy`.
- [x] **Parseo Estricto JSON**: Adaptado a los carnets reales del SENA (`nom`, `doc`, `cargo`, `rh`, `ficha`, `dep`, `prog`) con manejo seguro de `json.JSONDecodeError` y HTTP 400.
- [x] **Persistencia y Anti-Rebote**: Base de datos SQLite3 (`registro_aprendices.db`) con modo WAL y verificación diaria por `documento` y `fecha`.
- [x] **Soporte Escáner Físico USB**: Entrada por teclado HID con autofoco permanente en interfaz web (`index.html`).
- [x] **Soporte Móvil Dual**:
  - Modo cámara en vivo continua (`html5-qrcode`) servido a través del **túnel HTTPS de VS Code**.
  - Modo captura fotográfica (`/registrar_foto`) decodificado en backend con OpenCV y `pyzbar`.
- [x] **Feedback Multimedia**: Alertas visuales HUD (Verde, Naranja, Rojo) y audio sintético nativo con Web Audio API.
- [x] **Automatización Windows**: Script lanzador `iniciar_servidor.bat` (HTTP local).
- [x] **Pruebas Automatizadas**: 6/6 pruebas pasando en [`test_endpoints.py`](test_endpoints.py).
- [x] **Limpieza SSL/HTTPS local**: eliminados certificados (`cert.pem`, `key.pem`, `rootCA.*`), `generar_certificados.bat`, `habilitar_red_celular.bat`, `server_https.log` y la dependencia `cryptography`. El servidor arranca estrictamente en HTTP puro.
- [x] **Documentación**: `README.md` exhaustivo (con sección "Ejecución y Acceso desde Móvil") y `ESTADO_Y_DIAGNOSTICO_TECNICO.md` actualizado.

## Tarea Actual
- Arquitectura consolidada. El core (SQLite, anti-rebote, parseo JSON, endpoints) permanece intacto.

## Próximas Tareas
- [ ] Probar en producción con la pistola física USB conectada al equipo.
- [ ] Opcional: Empaquetar con servidor WSGI de producción (Waitress o Gunicorn) si se despliega en servidor dedicado.

## Problemas Conocidos
- La cámara en vivo continua en navegadores móviles requiere contexto seguro (HTTPS). Se resuelve con el **Port Forwarding de VS Code** (URL HTTPS de confianza), sin instalar certificados.
- El modo foto (`/registrar_foto`) no tiene esta restricción y funciona en cualquier red o navegador.

## Última Verificación Realizada
- `python test_endpoints.py` completado exitosamente (6/6 tests passing al 100%).
- Servidor arranca en HTTP puro (`app.run(host="0.0.0.0", port=5000)`), sin `ssl_context`.
