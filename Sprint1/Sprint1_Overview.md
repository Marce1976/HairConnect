# Sprint 1 - Overview

Duración: 2 semanas

Objetivo: Establecer la base de autenticación y datos en Firestore para soportar el MVP, con foco en clientes y salones y en la conexión Flutter + Firebase.

## Alcance
- Autenticación para clientes y salones (correo/Google).
- Modelos de datos en Firestore: salons, stylists, services, clients, bookings.
- Interfaces iniciales: login/registro, lista de salones, detalle de salón y servicios.
- Integración de Flutter con Firebase (cliente y panel).
- Configuración de reglas de seguridad y permisos.

## Historias de usuario principales
- HU1.1 Como cliente, quiero registrarme e iniciar sesión para usar la app.
- HU1.2 Como salón, quiero crear una cuenta y configurar mi perfil (servicios y horarios).
- HU1.3 Como usuario, quiero ver una lista de salones y sus servicios.

## Entregables
- Autenticación con Firebase para clientes y salones (correo/Google).
- Modelos de datos en Firestore: salons, stylists, services, bookings, clients.
- Estructuras de datos y reglas de seguridad básicas.
- Prototipos de UI: pantallas de login/registro, lista de salones, detalle de salón y servicios.
- Conexión de Flutter (cliente y panel) con Firebase.
- Documentación de arquitectura y modelos de datos.

## Backlog y tareas (Sprint 1)
- Configurar Firebase y activar Auth para clientes y salones.
- Crear colecciones iniciales: salons, stylists, services, clients, bookings.
- Configurar reglas de seguridad para Firestore.
- Crear proyectos Flutter para cliente y panel y conectar con Firebase.
- Integrar paquetes Firebase: firebase_core, firebase_auth, cloud_firestore, firebase_storage.
- Preparar archivos google-services.json y GoogleService-Info.plist.
- Construir pantallas de login/registro.
- Construir pantallas de lista de salones y detalle.
- Construir pantallas de servicios.
- Implementar flujo de reserva básico (sincronización).
- Probar sincronización en tiempo real.
- Configurar notificaciones básicas (push).
- Documentar arquitectura y esquemas de datos.

## Criterios de aceptación
- Registro/login funcional para clientes y salones.
- Estructuras de datos Firestore creadas y seguras.
- UI base conectada a Firebase con datos de prueba.
- Documentación de arquitectura y modelos de datos disponible.

## Riesgos y mitigaciones
- Riesgo: Configuración de reglas de seguridad; mitigación: revisión y pruebas.
- Riesgo: Desalineación entre cliente y panel en estructura de datos; mitigación: documentación y validación.
- Riesgo: Retrasos por permisos de Firebase; mitigación: checklist y cuentas compartidas.

## Plan de entrega
- Semana 1: Configuración y autenticación.
- Semana 2: Modelos de datos, pantallas y pruebas de sincronización.

## Notas
- Priorizar seguridad de Firestore y estructura de datos.
- Preparar para Sprint 2: Reserva, calendario básico y feed Look & Book.

End Sprint 1 Overview