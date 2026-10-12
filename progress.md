# Progress - Sistema de Control de Asistencia QR SENA

## Estado Actual
- **Fase**: Escaneo completo, documentación exhaustiva, empaquetado para control de versiones y despliegue a GitHub.
- **Fecha**: 2026-10-11
- **Repositorio**: `d:\Repositorios\Asistencia_QR`

## Tareas Completadas
- [x] **Backend REST**: Construido con Flask (`app.py`), endpoints `/`, `/registrar`, `/registrar_foto`, `/api/asistencias/hoy`.
- [x] **Parseo Estricto JSON**: Adaptado a los carnets reales del SENA (`nom`, `doc`, `cargo`, `rh`, `ficha`, `dep`, `prog`) con manejo seguro de `json.JSONDecodeError` y HTTP 400.
- [x] **Persistencia y Anti-Rebote**: Base de datos SQLite3 (`registro_aprendices.db`) con modo WAL y verificación diaria por `documento` y `fecha`.
- [x] **Soporte Escáner Físico USB**: Entrada por teclado HID con autofoco permanente en interfaz web (`index.html`).
- [x] **Soporte Móvil Dual**:
  - Modo cámara en vivo continua (`html5-qrcode`) sobre HTTPS con Autoridad Certificadora local (`rootCA.crt`).
  - Modo captura fotográfica (`/registrar_foto`) decodificado en backend con OpenCV y `pyzbar`.
- [x] **Feedback Multimedia**: Alertas visuales HUD (Verde, Naranja, Rojo) y audio sintético nativo con Web Audio API.
- [x] **Automatización Windows**: Scripts batch creados: `iniciar_servidor.bat`, `habilitar_red_celular.bat`, `generar_certificados.bat`.
- [x] **Pruebas Automatizadas**: 6/6 pruebas pasando en [`test_endpoints.py`](file:///d:/Repositorios/Asistencia_QR/test_endpoints.py).
- [x] **Seguridad y Limpieza**: Configurado `.gitignore` para excluir bases de datos, logs, temporales y claves criptográficas privadas (`.pem`, `.key`).
- [x] **Documentación**: `README.md` exhaustivo y `ESTADO_Y_DIAGNOSTICO_TECNICO.md` detallado.

## Tarea Actual
- Inicialización del repositorio Git local independiente en `Asistencia_QR`, creación del repositorio remoto en GitHub del usuario (`diarboledac`) y primer commit & push.

## Próximas Tareas
- [ ] Probar en producción con la pistola física USB conectada al equipo.
- [ ] Opcional: Empaquetar con servidor WSGI de producción (Waitress o Gunicorn) si se despliega en servidor dedicado.

## Problemas Conocidos
- La cámara en vivo continua en navegadores móviles requiere contexto seguro (HTTPS con CA local de confianza instalada en el dispositivo móvil, o túnel público con certificado SSL global).
- El modo foto (`/registrar_foto`) no tiene esta restricción y funciona en cualquier red o navegador.

## Última Verificación Realizada
- `python test_endpoints.py` completado exitosamente (6/6 tests passing al 100%).
- Sintaxis y tipado verificados sin advertencias.
