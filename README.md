# Lo Renaciente

Base inicial del proyecto con cuatro piezas:

- `apps/api`: API en `Fastify + TypeScript`.
- `apps/mobile`: app movil en `Flutter` conectada a la API por un endpoint `bootstrap`.
- `apps/web`: app web en `React + Vite`.
- `apps/admin`: panel admin en `React + Vite`.

## Estado actual

Esta version ya deja una base funcional del producto:

- API con dominio semilla para usuario, home, planes, servicios, especialistas, biblioteca, reservas, suscripcion, pagos y resumen admin.
- Endpoint agregado: `GET /api/bootstrap` para hidratar la app movil.
- Endpoint de escritura inicial: `POST /api/bookings`.
- Disponibilidad real por especialista, politica de reserva e historial de cambios en bookings.
- Chat 1:1 base, registro de dispositivos push y panel admin con endpoints propios.
- Storage real via `S3/MinIO` para avatares y archivos con proxy de lectura desde la API.
- Billing interno para suscripcion y reservas con historial de pagos, flujo sandbox y guardas por autenticacion/admin.
- App Flutter con navegacion principal y pantallas conectadas a datos reales del backend.
- Base web y base admin separadas del movil, consumiendo la misma API.
- Documentación de producto y arquitectura inicial.
- Capa persistente real para `auth`, `profile`, `bookings`, `sessions` y `bootstrap` cuando existe `DATABASE_URL`.
- Uso real de `Redis` para enfriar reenvio de OTP cuando `REDIS_URL` existe.
- Infraestructura local base con `PostgreSQL`, `Redis` y `MinIO` via `docker compose`.
- Health endpoint ampliado con estado de dependencias.

## Ejecutar la API

```bash
npm install
npm run dev:api
```

La API queda en `http://localhost:4000`.

Si quieres usar persistencia real:

```bash
cp apps/api/.env.example apps/api/.env
npm run infra:up
npm run api:migrate
npm run dev:api
```

La API carga `apps/api/.env` automaticamente. Si no defines `DATABASE_URL`, sigue funcionando en modo mock para no romper el flujo actual.

Rutas nuevas relevantes:

- `GET /api/specialists/:specialistId/availability`
- `POST /api/specialists/availability`
- `GET /api/bookings/:bookingId/policy`
- `GET /api/bookings/:bookingId/history`
- `GET|POST /api/chat/threads`
- `POST /api/chat/threads/:threadId/messages`
- `GET|POST|DELETE /api/push/devices`
- `POST /api/storage/uploads`
- `PUT /api/storage/uploads/:assetId/binary?token=...`
- `GET /api/storage/assets/:assetId`
- `GET /api/storage/assets/:assetId/content`
- `GET /api/admin/summary`
- `GET /api/admin/bookings`
- `GET /api/admin/users`
- `GET /api/admin/chat`
- `GET /api/payments/config`
- `GET /api/payments/history`
- `POST /api/payments/checkout`
- `POST /api/payments/:paymentId/confirm`
- `GET /api/subscriptions/current`
- `GET /api/subscriptions/history`
- `POST /api/subscriptions/cancel`

Notas operativas:

- `payments`, `subscriptions` y `admin` exigen token `Bearer`.
- El flujo de pagos actual es `sandbox`: genera `paymentCode` y `paymentUrl` internos para validar la logica sin depender todavia de Mercado Pago, App Store o Play Billing.

## Infraestructura local

Servicios disponibles por `docker compose`:

- `postgres`: `localhost:5432`
- `redis`: `localhost:6379`
- `minio`: `http://localhost:9000`
- consola MinIO: `http://localhost:9001`

Comandos:

```bash
npm run infra:up
npm run infra:down
npm run api:migrate
```

## Ejecutar la app móvil

```bash
cd apps/mobile
flutter pub get
flutter run
```

Para Android Emulator:

```bash
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:4000
```

Para iOS Simulator, macOS o Chrome:

```bash
flutter run --dart-define=API_BASE_URL=http://127.0.0.1:4000
```

Para un celular fisico en la misma red Wi-Fi:

```bash
flutter run --dart-define=API_BASE_URL=http://<IP-DE-TU-MAC>:4000
```

Ejemplo en esta maquina:

```bash
flutter run --dart-define=API_BASE_URL=http://192.168.1.158:4000
```

Para iPhone fisico, usa este flujo estable:

```bash
npm run dev:api
npm run mobile:ios:device
```

No uses `flutter run` a secas en iPhone fisico si luego quieres abrir la app como app normal. Ese flujo puede instalar una build `debug` que depende de Flutter tooling para lanzarse.

Mas detalle operativo:

- [docs/ios-device-run.md](/Users/mark/Desktop/APP%20DE%20LORE/docs/ios-device-run.md)

## Ejecutar web y admin

Web:

```bash
cp apps/web/.env.example apps/web/.env
npm run dev:web
```

Admin:

```bash
cp apps/admin/.env.example apps/admin/.env
npm run dev:admin
```

Builds:

```bash
npm run build:web
npm run build:admin
```

## Estructura

```text
apps/
  api/
  admin/
  mobile/
  web/
docs/
```

## Próximos pasos recomendados

1. Reemplazar el modo mock restante por `PostgreSQL` tambien en servicios, especialistas, contenido y admin.
2. Extender storage real a adjuntos de chat, exportaciones y biblioteca.
3. Integrar proveedores reales de pago y renovacion para `Mercado Pago`, `App Store` y `Play Billing`.
4. Extender permisos por rol mas alla de `admin` e integrar observabilidad productiva, colas y despliegue separado por entorno.
