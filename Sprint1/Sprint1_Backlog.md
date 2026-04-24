# Sprint 1 - Backlog (Autenticación y datos básicos)
## Objetivo
Autenticación para clientes y salones y definición del modelo de datos en Firestore. Entregar una base funcional para continuar con el MVP.

## Historias de usuario (HUs)
- HU1.1 Como cliente, quiero registrarme e iniciar sesión para usar la app.
- HU1.2 Como salón, quiero crear una cuenta y configurar mi perfil (servicios y horarios).
- HU1.3 Como usuario, quiero ver una lista de salones y sus servicios.

## Entregables de Sprint 1
- Autenticación con Firebase para clientes y salones (correo/Google).
- Modelos de datos en Firestore: salons, stylists, services, clients, bookings.
- Estructuras de datos y reglas de seguridad básicas.
- Prototipos de UI: pantallas de login/registro, lista de salones, detalle de salón y servicios.
- Conexión de Flutter (cliente y panel) con Firebase.
- Documentación de arquitectura y modelos de datos.

## Backlog de tareas (Sprint 1)
- Repositorio y Git
  - [ ] Crear estructura de carpetas para sprint 1: client/, salon_panel/, shared/, backend/ (Funciones Cloud).
  - [ ] Configurar README con pautas de desarrollo y convenciones.
  - [ ] Añadir .gitignore para Flutter, Firebase y herramientas de desarrollo.
- Firebase y backend
  - [ ] Crear proyecto Firebase HairConnect y configurar Auth (correo/Google) y Firestore.
  - [ ] Definir reglas básicas de seguridad para Firestore.
  - [ ] Configurar Storage si se planea almacenar imágenes (galería).
  - [ ] Documentar arquitectura de datos (diagrama mínimo y modelos de datos).
- Proyectos Flutter
  - [ ] Crear proyectos Flutter para cliente (client) y panel (panel).
  - [ ] Añadir paquetes base: firebase_core, firebase_auth, cloud_firestore, firebase_storage.
  - [ ] Configurar archivos de plataforma (google-services.json, GoogleService-Info.plist).
  - [ ] Crear scaffolding básico y conexión a Firebase.
- Documentación
  - [ ] Architecture.md: diagrama de alto nivel de flujo (cliente <-> salón <-> Firestore).
  - [ ] Data_Model.md: esquemas de colecciones y campos clave.
- Preparación de entorno
  - [ ] Guía de instalación de Flutter, Dart, IDEs y emuladores.
  - [ ] Pasos para pruebas básicas de conexión y autenticación.
- CI/CD y pipelines (opcional para Sprint 1)
  - [ ] Propuesta mínima de pipeline local (lint, pruebas simples) y plan de CI para futuros Sprints.

## Estructura de datos recomendada (Firestore)
- salons: { salon_id, nombre, ubicacion, servicios[], stylists[], rating, gallery }
- stylists: { stylist_id, salon_id, nombre, habilidades, horarios }
- services: { service_id, salon_id, nombre, duracion, precio }
- bookings: { booking_id, salon_id, stylist_id, client_id, service_id, datetime, status, notes }
- clients: { client_id, nombre, email, GoogleAccount }
- reviews: { review_id, booking_id, rating, comentario }
- loyalty: { client_id, points, tier }

## Criterios de aceptación de Sprint 1
- Registro/login funcional para clientes y salones.
- Estructuras de datos Firestore creadas y seguras.
- UI base conectada a Firebase con datos de prueba.
- Documentación de arquitectura y modelos de datos disponible.

## Riesgos y mitigaciones
- Riesgo: Configuración incorrecta de reglas de Firestore. Mitigación: revisión por CTO/CEO y pruebas con cuentas simuladas.
- Riesgo: Desalineación entre cliente y panel en la estructura de datos. Mitigación: validar el modelo de datos en Sprint 0 y revisiones rápidas.
- Riesgo: Retrasos por permisos de Firebase. Mitigación: establecer checklist de configuración y cuentas compartidas.

## Plan de entrega
- Día 1-2: Crear repo y estructura; iniciar Firebase.
- Día 3-5: Configurar proyectos Flutter y conexión a Firebase.
- Día 6-8: Definir arquitectura y modelos de datos; documentar.
- Día 9-10: Crear documentación de entorno y preparar Sprint 2.
- Revisión final: Verificar artefactos en docs/ y compilación de ejemplos básicos.

## Anexos
- Enlaces a guías de Firebase, Flutter + Firebase, y prácticas de seguridad.
  
Fin Sprint 1. Preparados para avanzar a Sprint 2: Reserva, calendario básico y feed Look & Book.