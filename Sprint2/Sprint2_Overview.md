# Sprint 2 - Overview

## Resumen del Sprint

**Duración:** 2 semanas

**Objetivo General:** Implementar el flujo de reserva end-to-end entre cliente y salón, activar el calendario básico para el panel de negocio y habilitar el feed visual Look & Book para iniciar reservas desde imágenes.

**Equipo:** CTO (Desarrollo y Tecnología), CMO (Comercial y Ventas), CEO (Gestión y Finanzas)

## Alcance Detallado

1.  **Para Clientes (App Flutter):**
    *   Pantalla de búsqueda de salones con filtros básicos (ubicación, servicios).
    *   Pantalla de detalle del salón: información, fotos, servicios disponibles, estilistas.
    *   Flujo de reserva completo: selección de servicio, estilista (si aplica), fecha y hora.
    *   Confirmación de reserva y visualización en el historial de citas del cliente.
    *   Feed visual Look & Book: mostrar galería de imágenes de trabajos, permitir reservar directamente desde una imagen.
    *   Conexión a Firebase para la creación de `bookings`.

2.  **Para Salones (Panel Web/App Flutter):**
    *   Vista de calendario: mostrar citas del día y la semana.
    *   Gestión básica de citas: ver detalles, actualizar estado (pendiente, confirmada, completada, cancelada).
    *   Gestión de servicios y estilistas (CRUD básico).
    *   Visualización de reservas provenientes del feed Look & Book.

3.  **Backend y Sincronización (Firebase):**
    *   Implementación de `bookings` con estados y temporalidad.
    *   Configuración de listeners de Firestore para sincronización en tiempo real de citas y disponibilidad.
    *   Actualización de reglas de seguridad en Firestore para roles de cliente y salón.

## Historias de Usuario (HUs) Principales

*   **HU2.1:** Como cliente, quiero buscar salones y servicios, seleccionar una franja horaria y reservar una cita fácilmente.
*   **HU2.2:** Como salón, quiero ver y gestionar mis citas del día/semana en un calendario claro y actualizar servicios/horarios básicos.
*   **HU2.3:** Como usuario, quiero poder reservar un servicio directamente desde una imagen atractiva en la galería Look & Book.

## Entregables Clave

*   Flujo de reserva completo y funcional de extremo a extremo.
*   Panel de calendario para salones con visualización de citas en tiempo real.
*   Feed Look & Book interactivo con capacidad de reserva directa.
*   Sistema de sincronización de datos en tiempo real operativo para citas.
*   Reglas de seguridad de Firestore actualizadas.
*   Flujos de datos y modelos de datos documentados.

## Plan de Ejecución (Estimación de 2 semanas)

**Semana 1:**
*   **CTO:** Implementar backend para reservas, configurar listeners en Firestore. Desarrollar pantallas de búsqueda y detalle de salón en cliente. Desarrollar vista de calendario en panel. Empezar flujo de reserva (selección de servicio/hora).
*   **CMO:** Preparar datos de prueba para salones, servicios y estilistas. Identificar 2-3 salones piloto en Vigo y coordinar la participación.
*   **CEO:** Revisar y refinar modelos de datos y reglas de seguridad. Preparar guía rápida de usuario para pilotos.

**Semana 2:**
*   **CTO:** Completar flujo de reserva end-to-end (creación de reserva, confirmación). Desarrollar feed Look & Book. Pruebas de sincronización en tiempo real. Tareas de debugging.
*   **CMO:** Coordinar con salones piloto, proveerles acceso y brief. Recoger feedback inicial.
*   **CEO:** Preparar plan de casos de prueba. Revisar diseño de flujo de reserva y Look & Book. Asegurar cumplimiento RGPD básico.

## Criterios de Aceptación

*   **Funcionalidad de Reserva:** El cliente puede buscar, seleccionar servicio/hora, y confirmar una reserva que se refleja instantáneamente en el panel del salón y en su historial de cliente.
*   **Calendario del Salón:** Muestra citas de forma correcta y se actualiza en tiempo real.
*   **Look & Book:** El feed visual permite seleccionar una imagen y navegar al flujo de reserva para ese servicio/trabajo.
*   **Sincronización:** Los cambios en la disponibilidad/reservas se reflejan sin demora significativa entre el cliente y el panel.
*   **Seguridad:** Las reglas de Firestore impiden accesos no autorizados a datos de salones/clientes/citas.
*   **Documentación:** Flujos de reserva y modelos de datos actualizados en `docs/`.

## Riesgos y Mitigaciones

*   **Riesgo:** Latencia o conflictos de concurrencia en la gestión de reservas en tiempo real.
    *   **Mitigación:** Implementar transacciones atómicas de Firestore para la creación de bookings. Pruebas exhaustivas con datos de alta concurrencia.
*   **Riesgo:** Complejidad de la UI/UX del feed Look & Book y reserva desde imagen.
    *   **Mitigación:** Validar prototipos en Figma y obtener feedback temprano de usuarios de prueba o pilotos.
*   **Riesgo:** Desalineación en el sistema de bloqueo de franjas horarias (disponibilidad).
    *   **Mitigación:** Definir claramente la lógica de disponibilidad (tiempos de servicio, márgenes, etc.) y validar con el equipo y pilotos.

## Próximos Pasos (para Sprint 3)

*   Notificaciones push mejoradas (recordatorios críticos, confirmaciones).
*   Sistema de fidelización de clientes.
*   Integración de sistema de valoración de servicios.
*   Mejoras en el panel de gestión (estadísticas, comunicación).

## Nota Final

Este sprint es crucial para validar la funcionalidad principal de la app y la experiencia de usuario central (Look & Book, reserva fácil). El enfoque en la sincronización en tiempo real y un piloto controlado sentarán las bases para la iteración y el crecimiento futuro.