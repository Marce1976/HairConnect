# Sprint 3 - Backlog (Pruebas Beta y Refinamiento)

## Objetivo
Validar el MVP con 2-3 salones piloto en Vigo, recopilar feedback y realizar mejoras iterativas en la UX de reserva, Look & Book, y notificaciones. Preparar la base para futuras mejoras de fidelización y panel.

## Historias de Usuario (HUs) Principales para Sprint 3

*   **HU3.1:** Como usuario de pruebas (salón piloto), quiero poder usar la app y el panel sin errores y reportar feedback fácilmente.
*   **HU3.2:** Como cliente, quiero que el proceso de reserva sea más intuitivo y que las notificaciones (confirmación, recordatorio) sean fiables.
*   **HU3.3:** Como salón, quiero que el feed Look & Book muestre mi trabajo de forma atractiva y que la reserva desde imagen sea sencilla.
*   **HU3.4:** Como desarrollador, quiero que el código base esté limpio, con pruebas unitarias y de integración para futuras expansiones.

## Backlog de Tareas (Sprint 3)

**1. Pruebas Piloto y Recopilación de Feedback (Responsable: CMO, CEO)
   - [ ] Identificar y contactar 2-3 salones piloto en Vigo, formalizar acuerdo de prueba (simple).
   - [ ] Coordinar onboarding de los salones piloto (acceso, datos iniciales, formación breve).
   - [ ] Establecer canal de comunicación con pilotos (ej. grupo de WhatsApp, Slack).
   - [ ] Implementar un sistema de feedback sencillo (ej. formulario online, chat directo).
   - [ ] Recoger feedback sobre usabilidad, bugs, y nuevas funcionalidades deseadas.
   - [ ] Observar el uso real de la app y panel.

**2. Mejoras en Flujo de Reserva y UX (Responsable: CTO)
   - [ ] Refinar el flujo de selección de servicio, estilista y hora basándose en feedback.
   - [ ] Optimizar la interfaz de usuario para mayor claridad y rapidez.
   - [ ] Implementar validaciones de disponibilidad más robustas para evitar conflictos de citas.
   - [ ] Mejorar la visualización del calendario en el panel de salón (colores, estados).
   - [ ] Corregir bugs detectados en el flujo de reserva.

**3. Mejoras en Look & Book y Galería (Responsable: CTO)
   - [ ] Optimizar la carga de imágenes en el feed Look & Book.
   - [ ] Simplificar el proceso de reserva desde una imagen del feed.
   - [ ] Permitir al salón subir imágenes de alta calidad y categorizarlas.
   - [ ] Asegurar que las reservas desde Look & Book se integren fluidamente con el calendario del salón.

**4. Notificaciones y Fidelización (Inicial) (Responsable: CTO)
   - [ ] Revisar y mejorar el sistema de notificaciones push (tiempos de recordatorio, contenido).
   - [ ] Implementar primera versión del sistema de fidelización (acumulación de puntos por reserva).
   - [ ] Crear la estructura de datos para puntos de fidelización.

**5. Pruebas, Calidad y Seguridad (Responsable: CTO, CEO)
   - [ ] Implementar pruebas unitarias para lógica clave (validación de reserva, cálculo de puntos).
   - [ ] Escribir pruebas de integración para el flujo end-to-end (cliente -> salón -> reserva).
   - [ ] Revisar y actualizar reglas de seguridad de Firestore según el uso real.
   - [ ] Realizar pruebas de rendimiento y estrés en base de datos.
   - [ ] Validar cumplimiento RGPD básico (consentimiento, política de privacidad).

**6. Documentación y Preparación (Responsable: CEO, CTO)
   - [ ] Actualizar docs/Architecture.md y Data_Model.md con cambios realizados.
   - [ ] Crear Sprint3_Review.md documentando decisiones, feedback y KPIs.
   - [ ] Preparar la documentación para el lanzamiento oficial (si es el caso).
   - [ ] Planificar para Sprint 4 (nuevos módulos, escalabilidad).

## Criterios de Aceptación de Sprint 3

*   **Piloto Exitoso:** Al menos 2 salones participan activamente en las pruebas beta y proporcionan feedback constructivo.
*   **UX Mejorada:** El feedback recopilado indica una mejora clara en la facilidad de uso del flujo de reserva y Look & Book.
*   **Funcionalidad Fiable:** El flujo de reserva end-to-end funciona sin errores críticos, las notificaciones son consistentes y los datos se sincronizan correctamente.
*   **Calidad del Código:** Cobertura mínima de pruebas unitarias en lógica crítica; corrección de bugs identificados.
*   **Seguridad:** Las reglas de Firestore no han sido comprometidas y protegen adecuadamente los datos.
*   **Documentación:** Los cambios y decisiones del sprint están documentados.

## Riesgos y Mitigaciones

*   **Riesgo:** Dificultad para conseguir participación activa de los pilotos o feedback de calidad.
    *   **Mitigación:** Ofrecer incentivos (descuentos futuros, soporte prioritario), hacer seguimiento cercano y personalizado.
*   **Riesgo:** Bugs críticos descubiertos durante las pruebas con pilotos.
    *   **Mitigación:** Tener un canal de comunicación directo y rápido para reportar y solucionar bugs de alta prioridad.
*   **Riesgo:** Resistencia a la adopción por parte de los pilotos.
    *   **Mitigación:** Sesiones de ayuda y formación extra, enfatizar el valor de la herramienta.

## Priorización de Tareas

1.  Pruebas Piloto y Feedback (CMO, CEO)
2.  Corrección de Bugs Críticos (CTO)
3.  Mejoras en Flujo de Reserva y UX (CTO)
4.  Mejoras en Look & Book / Galería (CTO)
5.  Notificaciones y Fidelización (versión 1) (CTO)
6.  Pruebas y Calidad (CTO, CEO)
7.  Documentación (CEO, CTO)

**Fin Sprint 3 Backlog.**
