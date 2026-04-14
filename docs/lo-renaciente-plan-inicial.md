# Lo Renaciente - Plan Inicial

## 1. Decisiones clave antes de programar

### No arrancar con microservicios
Para una v1, conviene un backend modular monolítico. Microservicios + Kubernetes agregan costo, DevOps, observabilidad y complejidad operativa demasiado pronto.

### Separar pagos por tipo de producto
No todo debe cobrarse igual:

- Premium digital dentro de la app: usar `Apple In-App Purchase` y `Google Play Billing`.
- Consultas 1:1 en tiempo real entre usuario y especialista: puede evaluarse `Mercado Pago` como pago externo, sujeto al flujo exacto.
- Servicios grabados, descargables o consumibles luego dentro de la app: tratarlos como contenido digital y validar si deben ir por billing de tienda.

### No construir chat/video desde cero en la v1
Para salir antes y con menos riesgo, conviene usar un proveedor gestionado para mensajería y/o video.

## 2. Qué falta definir

### Producto
- Qué incluye exactamente el plan gratuito.
- Qué incluye exactamente el plan premium.
- Qué servicio es en vivo, cuál es por chat, cuál es asincrónico y cuál deja contenido reutilizable.
- Si las lecturas diarias son generadas por especialista, por reglas fijas o por IA.
- Si la app será solo para Uruguay o multi-país desde el inicio.

### Operación
- Cómo se da de alta a los especialistas.
- Cómo se validan identidad, experiencia y disponibilidad.
- Cómo se reparten los cobros entre plataforma y especialista.
- Qué política habrá para cancelaciones, reembolsos y no-shows.
- Qué horarios, zonas horarias y monedas soportará la agenda.

### Legal
- Términos y condiciones.
- Política de privacidad.
- Consentimiento para datos personales y datos sensibles.
- Disclaimer para evitar promesas médicas, psicológicas, financieras o resultados garantizados.
- Definición fiscal: quién factura al usuario, la plataforma o el especialista.

## 3. MVP recomendado

### Usuario
- Registro e inicio de sesión.
- Perfil con nombre, fecha de nacimiento, hora y lugar de nacimiento.
- Carta del día.
- Energía astrológica básica.
- Agenda para reservar consultas.
- Pago de consultas.
- Suscripción premium.
- Chat 1:1 con límite por plan.
- Notificaciones push.

### Especialista
- Perfil profesional.
- Servicios ofrecidos.
- Calendario y disponibilidad.
- Confirmación, rechazo y reprogramación de reservas.
- Chat con usuarios.

### Admin
- Gestión de usuarios.
- Gestión de especialistas.
- Gestión de servicios, precios y planes.
- Gestión editorial de textos, cartas y contenido diario.
- Revisión de pagos, reservas, incidencias y reportes.

## 4. Arquitectura recomendada para v1

### Frontend
- `Flutter` para iOS y Android.

### Backend
- `NestJS` o `Laravel` como API principal.
- `PostgreSQL` como base de datos principal.
- `Redis` para colas, caché y jobs.
- `S3` o compatible para archivos.
- `Firebase Cloud Messaging` para push.

### Servicios externos recomendados
- Chat/video: `Stream`, `Twilio` o `Agora`.
- Analítica y errores: `PostHog` + `Sentry`.
- Correo transaccional: `Resend`, `SendGrid` o `Postmark`.

### Infraestructura
- Empezar con servicios gestionados.
- `Docker` sí.
- `Kubernetes` no en la primera etapa.
- Despliegue inicial viable: `Render`, `Railway`, `Fly.io`, `AWS ECS` o `Google Cloud Run`.

## 5. Modelo de módulos

- `auth`
- `users`
- `specialists`
- `services`
- `availability`
- `bookings`
- `payments`
- `subscriptions`
- `entitlements`
- `chat`
- `content`
- `notifications`
- `admin`
- `audit_logs`

## 6. Regla de pagos recomendada

### Usar billing de tienda
- Suscripción premium mensual o anual.
- Cursos exclusivos.
- Lectura diaria avanzada desbloqueada por plan.
- Funciones premium dentro de la app.

### Evaluar Mercado Pago
- Consulta 1:1 en tiempo real con especialista.
- Pago puntual por sesión individual.

### Riesgos a validar
- Si la consulta deja grabación o contenido reutilizable, puede dejar de calificar como simple servicio 1:1.
- Si dentro de la app empujas a pagar contenido digital por fuera, Apple o Google pueden rechazar la app.

## 7. Reglas de negocio que debes escribir antes de desarrollar

- Límite diario del plan gratuito.
- Cuántos mensajes incluye el chat limitado.
- Duración de cada tipo de consulta.
- Tiempo mínimo para cancelar o reprogramar.
- Comisión de la plataforma por consulta.
- Reglas de activación, renovación y cancelación de premium.
- Qué pasa si falla un pago.
- Qué pasa si el especialista no se presenta.

## 8. Datos que vas a guardar

- Usuario
- Datos natales
- Preferencias
- Especialistas
- Servicios y tarifas
- Slots de agenda
- Reservas
- Mensajes
- Pagos
- Suscripciones
- Permisos y entitlements
- Contenido editorial
- Logs de auditoría

## 9. Roadmap realista

### Fase 0
- PRD funcional.
- Mapa de pantallas.
- Reglas de monetización por plataforma.
- Términos, privacidad y definición fiscal.

### Fase 1
- Base Flutter.
- Backend base.
- Auth.
- Perfil.
- Carta del día.
- Agenda.
- Reserva de consultas.
- Admin básico.

### Fase 2
- Pagos.
- Suscripción premium.
- Chat 1:1.
- Push notifications.
- Campus de cursos.

### Fase 3
- Más especialistas.
- Astrología personalizada avanzada.
- Métricas.
- Automatizaciones.
- Optimización de escalado.

## 10. Recomendación final

La mejor optimización no es técnica, es de alcance:

- No lances todo a la vez.
- No uses microservicios al inicio.
- No mezcles en un mismo flujo pagos de contenido digital y pagos de consultas 1:1.
- No dejes para el final el panel admin, la moderación del chat ni la política de reembolsos.

## 11. Fuentes oficiales revisadas

- Apple App Review Guidelines: https://developer.apple.com/app-store/review/guidelines/
- Apple In-App Purchase: https://developer.apple.com/in-app-purchase/
- Google Play Payments policy: https://support.google.com/googleplay/android-developer/answer/10281818
- Google Play user choice billing: https://support.google.com/googleplay/android-developer/answer/13821247
- Ley 18.331 Uruguay, artículo 13: https://www.impo.com.uy/bases/leyes/18331-2008/13
- Ley 18.331 Uruguay, artículo 18: https://www.impo.com.uy/bases/leyes/18331-2008/18
- Mercado Pago status: https://status.mercadopago.com/
