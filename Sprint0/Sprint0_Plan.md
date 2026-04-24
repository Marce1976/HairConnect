# Sprint 0 - Preparación y Configuración

Duración: 2 semanas
Equipo: CTO, CMO, CEO
Objetivo general: Dejar el entorno listo para iniciar el desarrollo del MVP con Flutter + Firebase, definir la arquitectura y las bases de seguridad y datos.

1) Entregables
- Repositorio organizado y estructura de carpetas.
- Proyectos Flutter para cliente (app móvil) y panel de negocio (web/app).
- Proyecto Firebase creado (Auth, Firestore, Storage) con reglas básicas.
- Documentación inicial de arquitectura y flujo de datos.
- Guía de configuración de entorno de desarrollo para todos los miembros.

2) Historias de usuario (HUs) de Sprint 0
- HU0.1 Como CTO, quiero una estructura de repositorio clara para empezar a trabajar sin ambigüedades.
- HU0.2 Como CTO, quiero un proyecto Firebase con autenticación y reglas seguras para proteger datos.
- HU0.3 Como equipo, quiero una guía de arquitectura y flujos de datos para alinear al desarrollo.

3) Backlog de tareas (Sprint 0)
- Repositorio y organización
  - Crear estructura de carpetas: client/, salon_panel/, shared/, backend/ (Funciones Cloud si se usan).
  - Inicializar Git, crear README.md con pauta de desarrollo y convenciones.
  - Configurar .gitignore para Flutter, Firebase y herramientas de desarrollo.
- Firebase y backend
  - Crear proyecto Firebase HairConnect (o hairconnect).
  - Habilitar Firebase Auth (correo/Google) y Firestore; configurar reglas básicas de seguridad.
  - Configurar Storage para imágenes (galería) si aplica.
  - Crear documentación de la arquitectura de datos (diagrama mínimo y modelos de datos).
- Proyectos Flutter
  - Crear proyecto Flutter para cliente (client) y para panel (panel).
  - Integrar paquetes base: firebase_core, firebase_auth, cloud_firestore, firebase_storage.
  - Preparar ejemplos de conexión con Firebase y limpieza de credenciales (configurar archivos google-services.json y GoogleService-Info.plist en sus plataformas).
- Documentación
  - Crear docs/Architecture.md con diagramas de alto nivel (cliente <-> salón <-> Firestore).
  - Crear docs/Data_Model.md con esquemas de colecciones (salons, stylists, services, bookings, clients, reviews, loyalty).
- Preparación de entorno
  - Guía de instalación de Flutter, Dart, VS Code/Android Studio.
  - Pasos para configurar emuladores/simuladores y pruebas básicas.
- CI/CD y pipelines (opcional para Sprint 0)
  - Definir una propuesta mínima de pipeline local (lint, pruebas unitarias simples si aplica) y plan de integración continua para futuros Sprints.

4) Dependencias
- Acceso a cuentas de Firebase y Google Cloud.
- Herramientas de desarrollo instaladas (Flutter, Dart, VS Code/Android Studio, Git).
- Conexión a internet estable para pruebas de sincronización en tiempo real.

5) Criterios de aceptación de Sprint 0
- Repositorio organizado con carpetas claramente definidas y README documentado.
- Proyecto Firebase creado con Auth, Firestore y Storage habilitados, reglas básicas definidas.
- Proyectos Flutter cliente y panel creados y conectados a Firebase (configuración inicial completada).
- Documentación inicial de arquitectura y modelos de datos disponible en docs/.
- Plan de Sprint 1 preparado con historias de usuario y criterios de aceptación.

6) Riesgos y mitigaciones
- Riesgo: Configuración incorrecta de reglas de Firestore.
  Mitigación: Revisiones de seguridad entre CTO y CEO; pruebas con usuarios simulados para validar permisos.
- Riesgo: Desalineación entre cliente y panel en la estructura de datos.
  Mitigación: Documentar claramente el modelo de datos en Sprint 0 y validar en reuniones rápidas.
- Riesgo: Retrasos por configuración de permisos de Firebase.
  Mitigación: Crear cuentas compartidas y establecer una checklist de configuración para evitar omisiones.

7) Plan de entrega
- Día 1-2: Crear repos y estructura; iniciar Firebase.
- Día 3-5: Configurar Flutter projects y conectar con Firebase.
- Día 6-8: Definir y documentar arquitectura y modelos de datos.
- Día 9-10: Crear documentación de entorno y preparar Sprint 1.
- Revisión final: Asegurar que todos los artefactos estén en docs/ y que el repositorio compile con ejemplos básicos.

Anexos
- Enlaces: documentación de Google Firebase, guías de Flutter + Firebase, pautas de seguridad y best practices.

Fin Sprint 0. Preparados para empezar Sprint 1: Autenticación y datos básicos.