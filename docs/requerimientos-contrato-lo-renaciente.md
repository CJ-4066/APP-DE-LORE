# Documento de requerimientos para contrato - Lo Renaciente

> Este documento es una base técnica y funcional para anexar a un contrato de desarrollo de software. No reemplaza la revisión de un abogado. Los importes, fechas, jurisdicción, garantías, penalidades, titularidad de activos y condiciones comerciales deben completarse en el contrato principal.

## 1. Identificación del proyecto

- Nombre del producto: Lo Renaciente.
- Tipo de producto: aplicación móvil con backend, tienda virtual, agenda de consultas, cursos/contenido, comunidad y panel administrativo.
- Plataformas objetivo: iOS y Android mediante Flutter.
- Componentes del repositorio:
  - `apps/mobile`: aplicación móvil en Flutter.
  - `apps/api`: API backend en Fastify + TypeScript.
  - `apps/web`: base web en React + Vite.
  - `apps/admin`: base de panel administrativo en React + Vite.
  - `docs`: documentación técnica y operativa.
- Objetivo del producto: permitir que usuarios/clientes consuman servicios espirituales o de autoconocimiento, compren productos, tomen cursos, reserven consultas e interactúen con comunidad; y que especialistas administren servicios, precios, agenda, tienda, cursos/materiales y comunidad.

## 2. Alcance general del sistema

El sistema debe contemplar tres perspectivas principales:

- Cliente o usuario final: navega la aplicación, completa su perfil, consume contenido, compra productos, reserva consultas, toma cursos y participa en comunidad.
- Especialista: administra su práctica dentro de la app, incluyendo precios de consultas, citas, productos, materiales, cursos/PDF, fotos y comunicación con comunidad.
- Administrador de plataforma: supervisa usuarios, especialistas, reservas, pagos, incidentes, contenido, tienda y operación general.

La aplicación debe ser funcional, visualmente cuidada, sin redundancias innecesarias y con una base de datos preparada para crecimiento progresivo.

## 3. Roles y permisos

### Cliente

- Puede registrarse o iniciar sesión.
- Puede elegir perfil de tipo cliente al completar datos.
- Puede consultar home, tarot, astrología, numerología, tienda, cursos y reservas.
- Puede comprar productos en la tienda.
- Puede reservar consultas con especialistas.
- Puede consultar sus propias órdenes y reservas.
- Puede participar en comunidad según reglas del producto.

### Especialista

- Puede elegir perfil de tipo especialista al completar datos.
- Puede acceder a un panel operativo especializado.
- Puede gestionar precios y duración de sus consultas.
- Puede gestionar citas y cambiar estados operativos.
- Puede administrar productos de tienda cuando tenga permisos.
- Puede agregar o actualizar fotos de productos mediante URL.
- Puede acceder a cursos/PDF y materiales.
- Puede interactuar con comunidad.
- No debe ver flujos duplicados o confusos de cliente cuando esté en modo especialista; la navegación debe priorizar administración.

### Administrador

- Puede consultar resumen administrativo.
- Puede revisar usuarios, reservas, chat, pagos e incidencias.
- Puede operar endpoints protegidos por rol `admin`.
- Debe existir separación entre permisos de cliente, especialista y administrador.

## 4. Requerimientos funcionales por módulo

### 4.1 Autenticación y perfil

- El sistema debe permitir inicio de sesión por teléfono mediante OTP.
- El flujo debe permitir completar datos personales base.
- El perfil debe incluir:
  - nombre;
  - apellido;
  - correo opcional;
  - teléfono;
  - ciudad, país y ubicación de nacimiento;
  - fecha de nacimiento;
  - hora de nacimiento;
  - zona horaria;
  - coordenadas;
  - signo zodiacal inferido cuando corresponda;
  - tipo de cuenta: `client` o `specialist`.
- Al iniciar sesión o completar perfil, el usuario debe poder elegir si entra como cliente o especialista.
- La API debe persistir `accountType` en la base de datos.
- Los usuarios existentes deben recibir un valor por defecto o migración segura.

### 4.2 Home y experiencia inicial

- El usuario debe recibir un `bootstrap` inicial desde API con los datos necesarios para cargar la app.
- El home debe mostrar contenido diario, próximos eventos y accesos relevantes.
- La experiencia debe diferenciar el acceso de cliente y especialista.
- El home debe evitar estados vacíos sin explicación.

### 4.3 Tarot

- Debe existir un módulo de tarot con cartas, imágenes y contenido asociado.
- Las imágenes de tarot deben ser coherentes con la carta o deck.
- Para productos de tarot en tienda, las imágenes deben corresponder al deck o, si el producto es ficticio, a una referencia visual claramente coherente sin presentarla como marca real.

### 4.4 Astrología

- Debe existir módulo de astrología con carta natal y cálculos base.
- Debe usarse la información natal del perfil.
- Debe existir soporte de ciudad, país, zona horaria, latitud y longitud.
- Debe contemplarse información astrológica personalizada y eventos.

### 4.5 Numerología

- Debe existir módulo de numerología con cálculos y guía inicial.
- Debe usar información del perfil cuando aplique.
- Debe permitir generar o consultar perfil numerológico.

### 4.6 Agenda y reservas

- El cliente debe poder reservar consultas.
- El especialista debe poder administrar citas.
- Las reservas deben incluir:
  - usuario;
  - servicio;
  - especialista;
  - fecha/hora;
  - modalidad;
  - estado;
  - precio;
  - notas.
- Estados mínimos:
  - pendiente de pago;
  - confirmada;
  - completada;
  - cancelada.
- Deben existir reglas para evitar modificar reservas canceladas o completadas sin política explícita.
- Deben definirse en contrato las reglas comerciales de cancelación, reprogramación, no-show, reembolso y comisión.

### 4.7 Servicios y consultas

- El catálogo de servicios debe incluir nombre, categoría, descripción, duración, precio, moneda, modalidades y especialistas asociados.
- El especialista autorizado debe poder modificar precio y duración.
- Las modificaciones de precios y duración deben persistirse en base de datos.
- Los cambios no deben duplicar el catálogo público ni crear registros redundantes.

### 4.8 Tienda virtual

- La tienda debe permitir visualizar productos por categoría.
- Los productos deben incluir:
  - nombre;
  - categoría;
  - descripción corta;
  - descripción completa;
  - precio;
  - moneda;
  - imagen;
  - arte/fallback visual;
  - etiqueta;
  - estado de stock;
  - tags;
  - indicador de destacado.
- El cliente debe poder agregar productos al carrito.
- El cliente debe poder crear órdenes de compra.
- El especialista autorizado debe poder administrar productos, destacados, stock y fotos.
- La imagen del producto debe ser coherente con el producto.
- No se deben usar imágenes aleatorias o engañosas.
- Para productos reales, la imagen debe ser del producto o de una fuente verificable.
- Para productos ficticios o seed, la imagen debe ser referencial de la misma categoría y no debe presentarse como foto exacta de una marca real.
- Las órdenes deben persistirse en base de datos cuando la API esté en modo persistente.
- La tienda debe ocultar funciones administrativas a clientes.

### 4.9 Cursos, PDF y materiales

- La app debe incluir sección de cursos y contenido educativo.
- El especialista debe poder acceder a una zona orientada a cursos/PDF/materiales.
- El contrato debe definir si el alcance incluye solo visualización seed o administración completa de cursos.
- Para una versión robusta, debe incluirse:
  - carga de PDF;
  - carga de imágenes de portada;
  - módulos y lecciones;
  - estado publicado/borrador;
  - validación de tamaño y tipo de archivo;
  - almacenamiento en S3/MinIO o compatible;
  - permisos por rol.

### 4.10 Comunidad y chat

- Debe existir módulo de chat o comunidad.
- El especialista debe poder abrir comunidad desde su panel.
- El sistema debe contemplar mensajes, autor, fecha, hilo y permisos.
- El contrato debe definir si la comunidad será chat global, chat por curso, chat 1:1 o combinación de estos.
- Deben definirse reglas de moderación, bloqueo, reporte y eliminación de contenido.

### 4.11 Pagos y suscripciones

- El sistema contempla configuración de pagos y suscripción.
- Para producción, deben definirse proveedores reales:
  - Mercado Pago para consultas o compras físicas cuando aplique.
  - Apple In-App Purchase para contenido digital dentro de iOS cuando aplique.
  - Google Play Billing para contenido digital dentro de Android cuando aplique.
- El contrato debe definir:
  - quién cobra;
  - quién factura;
  - comisión de plataforma;
  - moneda;
  - impuestos;
  - reembolsos;
  - contracargos;
  - liquidación a especialistas;
  - restricciones de Apple/Google para compras digitales.
- El flujo actual puede operar en modo sandbox para validación, pero producción requiere integración real.

### 4.12 Notificaciones push

- Debe existir base para registrar dispositivos push.
- Debe definirse el proveedor definitivo de notificaciones.
- Casos mínimos:
  - recordatorio de cita;
  - cambio de estado de reserva;
  - confirmación de compra;
  - mensaje de comunidad o chat;
  - nuevo curso/material publicado.

### 4.13 Storage y archivos

- El backend debe soportar carga de archivos vía S3/MinIO o proveedor compatible.
- Debe existir almacenamiento para:
  - avatares;
  - imágenes de producto;
  - adjuntos de chat;
  - PDFs y materiales;
  - exportaciones administrativas.
- Deben definirse límites de peso, formatos permitidos, compresión, privacidad y vida útil de URLs.
- Para producción, las imágenes comerciales finales deben ser entregadas por el cliente o contar con licencia adecuada.

## 5. Requerimientos de base de datos

La base de datos debe usar PostgreSQL como almacenamiento principal.

Tablas y dominios mínimos contemplados:

- usuarios;
- identidades telefónicas;
- sesiones;
- códigos OTP;
- reservas;
- disponibilidad de especialistas;
- dispositivos push;
- hilos y mensajes de chat;
- logs de auditoría;
- archivos;
- roles de usuario;
- suscripciones;
- transacciones de pago;
- tipo de cuenta (`account_type`);
- overrides de servicios;
- overrides de productos;
- órdenes de tienda;
- ítems de órdenes.

Migraciones existentes en el proyecto:

- `001_initial_schema.sql`: usuarios, auth, reservas, disponibilidad, push, chat y auditoría.
- `002_file_assets.sql`: activos de archivos.
- `003_roles_billing.sql`: roles, suscripciones y pagos.
- `004_account_type.sql`: tipo de cuenta cliente/especialista.
- `005_specialist_workspace_persistence.sql`: persistencia de servicios, productos y órdenes de tienda.

Requisitos de datos:

- Las migraciones deben ser idempotentes cuando aplique.
- La API debe poder arrancar en modo base de datos cuando exista `DATABASE_URL`.
- La API puede mantener modo mock/seed solo como soporte de desarrollo.
- Los datos administrados por especialista no deben perderse al reiniciar la API.
- No debe existir duplicación innecesaria entre catálogo seed y overrides persistidos.

## 6. Requerimientos visuales y UX

- La estética debe ser consistente con una app espiritual, boutique, premium y clara.
- Debe evitarse una apariencia genérica o descuidada.
- La navegación debe ser clara para cliente y especialista.
- La vista Shop debe usar imágenes coherentes con cada producto.
- Las imágenes deben tener buena calidad visual y fallback si falla la carga.
- Los estados vacíos deben explicar qué ocurrirá cuando haya datos.
- Las acciones administrativas deben estar separadas de acciones de compra.
- El diseño debe funcionar en móvil real, no solo en simulador.

## 7. Requerimientos técnicos

### Backend

- Fastify + TypeScript.
- PostgreSQL para persistencia.
- Redis para control de reenvío OTP/caché cuando esté configurado.
- MinIO/S3 compatible para archivos.
- Migraciones controladas por scripts.
- Endpoints REST organizados por módulo.
- Manejo de errores con mensajes claros.
- Protección por token Bearer.
- Separación de permisos por rol.

### Mobile

- Flutter.
- Configuración por `API_BASE_URL`.
- Soporte para dispositivo físico iOS.
- Manejo de imágenes remotas por URL.
- Fallback visual cuando no exista imagen.
- Navegación diferenciada por `accountType`.
- Análisis estático limpio con `flutter analyze`.

### Web/Admin

- React + Vite como base.
- Debe consumir la misma API.
- El alcance actual puede considerarse base técnica inicial salvo que el contrato incluya panel admin completo.

## 8. Entregables esperados

- Código fuente de app móvil.
- Código fuente de API.
- Base web/admin si se contrata.
- Migraciones SQL.
- Docker Compose local para Postgres, Redis y MinIO.
- Documentación de instalación y ejecución.
- Documento de requerimientos.
- Build instalable en dispositivo para validación.
- Evidencia de validación técnica mínima:
  - build de API correcto;
  - análisis Flutter sin errores;
  - API respondiendo en LAN;
  - app instalada en dispositivo físico.

## 9. Criterios de aceptación

Se considerará aceptado un módulo cuando cumpla estas condiciones:

- El flujo puede ejecutarse desde la app sin romper navegación.
- La API responde correctamente para los casos esperados.
- Los datos críticos se persisten cuando el modo base de datos está activo.
- La UI no muestra controles administrativos a usuarios sin permisos.
- Los errores se muestran de forma comprensible.
- La app compila y se instala en dispositivo físico.
- `npm run build:api` no falla.
- `flutter analyze` no reporta errores.
- Las imágenes de Shop cargan desde URL o muestran fallback sin romper.
- Los cambios no introducen duplicaciones innecesarias.

## 10. Alcance de MVP sugerido

### Fase 1 - Base funcional

- Login por teléfono.
- Perfil completo con tipo de cuenta.
- Home.
- Tarot.
- Astrología base.
- Numerología base.
- Tienda con catálogo y carrito.
- Reservas.
- Panel especialista básico.
- Gestión de precio/duración de consultas.
- Gestión básica de productos y stock.
- Persistencia PostgreSQL para datos críticos.
- Instalación en iPhone físico para validación.

### Fase 2 - Operación robusta

- Upload real de imágenes de producto.
- Upload real de PDFs y materiales.
- Administración completa de cursos.
- Comunidad con moderación.
- Gestión avanzada de agenda/disponibilidad.
- Integración real de pagos.
- Push notifications.
- Panel admin web completo.

### Fase 3 - Producción y escalamiento

- Observabilidad.
- Métricas.
- Backups.
- Gestión de entornos.
- Seguridad reforzada.
- Hardening de permisos.
- Auditoría operativa.
- Optimización de imágenes.
- Revisión legal y publicación en tiendas.

## 11. Exclusiones o puntos a definir antes de producción

- No se considera completada una integración real de pagos si solo existe modo sandbox.
- No se considera completado upload de PDF si solo existe visualización seed.
- No se considera completado marketplace multi-especialista si no hay onboarding, verificación y liquidación.
- No se considera completado cumplimiento legal si no existen términos, privacidad, consentimiento de datos y disclaimers.
- No se garantiza aceptación en App Store o Google Play sin revisar reglas de compras digitales, contenido sensible y políticas de pagos.
- No se deben usar imágenes externas en producción sin revisar licencia y atribución.
- No se deben prometer resultados médicos, psicológicos, financieros, espirituales o terapéuticos garantizados.

## 12. Responsabilidades del cliente

- Entregar marca, logo, paleta, textos legales y lineamientos visuales finales.
- Entregar imágenes propias o licencias de imágenes de productos reales.
- Definir precios finales, comisiones, monedas e impuestos.
- Definir reglas de cancelación, reembolso, no-show y atención al cliente.
- Definir quién factura al usuario.
- Definir países de operación.
- Definir políticas de moderación de comunidad.
- Definir datos requeridos para especialistas.
- Validar contenido esotérico, cursos, PDFs y claims comerciales.
- Aprobar diseño y flujo antes de publicación.

## 13. Responsabilidades del equipo de desarrollo

- Implementar los módulos contratados conforme al alcance aprobado.
- Mantener código ordenado y modular.
- Evitar duplicación innecesaria.
- Documentar ejecución local y configuración básica.
- Implementar migraciones de base de datos necesarias.
- Aplicar validaciones y permisos razonables para cada rol.
- Ejecutar validaciones técnicas antes de entrega.
- Reportar bloqueos por dependencias externas, credenciales, licencias o decisiones comerciales pendientes.

## 14. Riesgos principales

- Rechazo de tiendas por reglas de pagos digitales si se intenta cobrar contenido digital por fuera de Apple/Google.
- Uso de imágenes sin licencia adecuada.
- Falta de definición fiscal sobre facturación y liquidación a especialistas.
- Falta de políticas de reembolso y cancelación.
- Falta de moderación en comunidad.
- Exposición de datos sensibles sin política de privacidad suficiente.
- Crecimiento de alcance sin separar MVP, fase 2 y producción.

## 15. Estado técnico actual de referencia

El proyecto cuenta con una base funcional que incluye:

- API modular.
- App móvil Flutter.
- Login por teléfono.
- Perfil con tipo de cuenta.
- Modo cliente y modo especialista.
- Shop con imágenes remotas por producto.
- Gestión básica de productos.
- Gestión de precios de servicios.
- Gestión de citas.
- Persistencia PostgreSQL para datos críticos agregados.
- Redis y MinIO en infraestructura local.
- Reinstalación validada en iPhone físico.

Este estado debe ser verificado nuevamente antes de firmar un contrato, ya que el alcance contractual debe reflejar una versión, fecha y commit o entrega específica.

## 16. Anexo sugerido de aceptación por hitos

- Hito 1: arquitectura base, API, app móvil y bootstrap.
- Hito 2: autenticación, perfil y roles.
- Hito 3: módulos de contenido: home, tarot, astrología y numerología.
- Hito 4: reservas y servicios.
- Hito 5: tienda, productos, imágenes y órdenes.
- Hito 6: especialista, administración y comunidad base.
- Hito 7: storage, cursos/PDF y uploads.
- Hito 8: pagos reales y suscripciones.
- Hito 9: panel admin, QA, hardening y preparación para publicación.

Cada hito debe tener fecha, precio, entregables, responsable de aprobación y criterio de aceptación firmado.
