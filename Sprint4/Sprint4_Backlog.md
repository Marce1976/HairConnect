# Sprint 4 - Backlog (Ampliación Piloto, Fidelización y Panel)

## Objetivo General
Ampliar el programa piloto a 3-4 salones en Vigo, implementar una versión inicial de fidelización, mejorar el panel de negocio y explorar la integración con sistemas de facturación/TPV, todo enfocado en la escalabilidad.

## Historias de Usuario (HUs) Principales para Sprint 4

*   **HU4.1:** Como salón (nuevo piloto), quiero un proceso de onboarding rápido y recibir soporte para empezar a usar HairConnect.
*   **HU4.2:** Como cliente, quiero ver mis puntos de fidelización y poder canjearlos por ofertas o descuentos.
*   **HU4.3:** Como salón, quiero acceder a un panel de negocio con métricas clave (ingresos, ocupación, valoraciones) y notificaciones personalizables.
*   **HU4.4:** Como CEO/CTO, quiero explorar y prototipar la integración con sistemas de Facturación/TPV para salones.
*   **HU4.5:** Como desarrollador, quiero que el código sea optimizado para un mayor volumen de usuarios y que las reglas de seguridad sean robustas.

## Backlog Detallado de Tareas (Sprint 4)

**1. Ampliación del Piloto y Onboarding (Responsable: CMO, CEO)
   - [ ] Identificar y contactar 1-2 salones piloto adicionales en Vigo.
   - [ ] Desarrollar un proceso de onboarding más estructurado (guía rápida, video tutorial, sesión Q&A).
   - [ ] Asegurar que los nuevos pilotos configuren su perfil, servicios y equipo correctamente.
   - [ ] Mantener comunicación fluida con todos los pilotos activos.

**2. Implementación de Fidelización (Versión 1.0) (Responsable: CTO)
   - [ ] Diseñar el sistema de acumulación de puntos (ej. puntos por euro gastado, por reserva completada).
   - [ ] Crear modelos de datos en Firestore para 'loyalty_points' y 'promotions'.
   - [ ] Desarrollar la UI del cliente para mostrar puntos acumulados y disponibles.
   - [ ] Implementar la lógica de canje de puntos por descuentos en el flujo de reserva.
   - [ ] Permitir al salón crear y gestionar promociones básicas asociadas a puntos.
   - [ ] Pruebas unitarias y de integración para la lógica de puntos y canje.

**3. Mejoras en el Panel de Negocio (Responsable: CTO)
   - [ ] Diseñar e implementar un dashboard con KPIs clave: ingresos totales, ocupación media, número de citas, valoraciones promedio.
   - [ ] Desarrollar un sistema de notificaciones personalizables para el salón (ej. bajas ocupaciones, nuevas valoraciones).
   - [ ] Implementar filtros en el calendario y la lista de citas (por estilista, por fecha, por estado).
   - [ ] Visualizar de forma intuitiva las estadísticas de negocio.

**4. Exploración de Integración Facturación/TPV (Responsable: CEO, CTO)
   - [ ] Investigar APIs de sistemas de facturación/TPV comunes en el sector peluquería en España (ej. A3, Sage, software local).
   - [ ] Realizar pruebas conceptuales (Proofs of Concept - PoC) de conexión con una API seleccionada.
   - [ ] Documentar los requisitos técnicos y el esfuerzo estimado para una integración real.
   - [ ] Realizar un análisis costo-beneficio de la integración.

**5. Optimización, Seguridad y Calidad (Responsable: CTO, CEO)
   - [ ] Optimizar consultas a Firestore para mejorar el rendimiento con más datos.
   - [ ] Revisar y reforzar reglas de seguridad de Firestore ante mayor volumen de datos y usuarios.
   - [ ] Implementar pruebas de rendimiento y estrés en el sistema (simulando uso intensivo).
   - [ ] Continuar con pruebas unitarias y de integración para nuevas funcionalidades.
   - [ ] Asegurar que el código cumpla con las guías de estilo.

**6. Documentación y Preparación (Responsable: CEO, CTO)
   - [ ] Actualizar la documentación técnica (`Architecture.md`, `Data_Model.md`) con los cambios de fidelización y panel.
   - [ ] Crear Sprint4_Review.md documentando decisiones, feedback, KPIs y plan para Sprint 5.
   - [ ] Preparar el plan de pruebas y casos de uso para Sprint 4.

## Criterios de Aceptación de Sprint 4

*   **Piloto Ampliado:** Al menos 3-4 salones piloto activos y funcionando eficientemente.
*   **Fidelización V1:** El sistema de puntos y canje funciona correctamente en cliente y salón; se pueden generar y aplicar promociones básicas.
*   **Panel Mejorado:** Las métricas clave son visibles y los KPIs están disponibles y actualizados.
*   **Integración TPV/Facturación:** Se ha emitido un informe conceptual con requisitos técnicos y estimaciones de esfuerzo.
*   **Rendimiento y Seguridad:** Mejoras demostrables en rendimiento (tiempos de carga, sincronización) y la seguridad de Firestore es robusta.
*   **Documentación:** La documentación técnica está actualizada y refleja los avances.

## Riesgos y Mitigaciones

*   **Riesgo:** Complejidad de la lógica de fidelización y promociones.
    *   **Mitigación:** Empezar con un modelo de puntos simple y expandir gradualmente. Validar la lógica con pruebas exhaustivas.
*   **Riesgo:** Retraso en el onboarding de los nuevos salones piloto.
    *   **Mitigación:** Crear guías de onboarding muy claras y ofrecer sesiones de soporte dedicadas.
*   **Riesgo:** Dificultad para integrar con sistemas de TPV/Facturación externos.
    *   **Mitigación:** Empezar por investigar APIs comunes y realizar solo pruebas conceptuales simples, sin comprometer el desarrollo principal.
*   **Riesgo:** Aumento de costos en Firebase por mayor volumen y uso de Cloud Functions.
    *   **Mitigación:** Monitorear el uso de Firebase y optimizar consultas. Buscar configuraciones de precios adecuadas.

## Priorización de Tareas (Estimada)

1.  Onboarding de Nuevos Pilotos y Soporte (CMO, CEO)
2.  Fidelización V1 (CTO)
3.  Mejoras en Panel de Negocio (CTO)
4.  Pruebas de Rendimiento y Seguridad (CTO, CEO)
5.  Exploración TPV/Facturación (CEO, CTO)
6.  Documentación y Revisión (CEO, CTO)

**Fin Sprint 4 Backlog.**
