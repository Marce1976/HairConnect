# Sprint 7 - Backlog (Monetización y Expansión)

## Objetivo General
Lanzar la monetización a los primeros salones piloto, iniciar la expansión geográfica fuera de Vigo, consolidar la integración de TPV/Facturación y definir el roadmap de producto V2.

## Historias de Usuario (HUs) Principales para Sprint 7

*   **HU7.1:** Como administrador/CEO, quiero poder configurar y lanzar los planes de suscripción y precios, así como integrar pasarelas de pago.
*   **HU7.2:** Como cliente (salón), quiero poder seleccionar un plan de suscripción, realizar el pago y gestionar mi suscripción.
*   **HU7.3:** Como equipo, quiero tener la infraestructura y los materiales preparados para iniciar la expansión a una nueva ciudad (ej. A Coruña).
*   **HU7.4:** Como CEO/CTO, quiero tener un plan avanzado para la integración de TPV/Facturación y un roadmap para la versión V2.

## Backlog Detallado de Tareas (Sprint 7)

**1. Implementación de Monetización y Pagos (Responsable: CTO)**
- [ ] Diseñar y configurar las estructuras de datos para suscripciones y planes de pago.
- [ ] Integrar el módulo de pagos con una pasarela principal (ej. Stripe) para la aceptación de pagos recurrentes.
- [ ] Desarrollar el flujo de usuario para la selección de plan, suscripción y pago.
- [ ] Implementar la gestión de suscripciones (altas, bajas, actualizaciones).
- [ ] Configurar notificaciones de pago (éxito, fallo, recordatorios).
- [ ] Pruebas unitarias y de integración para el flujo de pago y gestión de suscripciones.

**2. Preparación para Expansión Geográfica (Responsable: CMO)**
- [ ] Investigar el mercado de peluquerías en una ciudad objetivo (ej. A Coruña): competencia, tamaño, adopción digital.
- [ ] Adaptar los materiales de marketing y onboarding para el nuevo mercado (idioma, referencias locales si aplica).
- [ ] Definir la estrategia de prospección y captación de salones en la nueva ciudad.
- [ ] Preparar la infraestructura técnica para soportar nuevas localizaciones (ej. geonotificaciones, contenido localizable).

**3. Consolidación TPV/Facturación (Responsable: CEO, CTO)**
- [ ] Revisar el informe PoC y definir los requisitos técnicos para una integración real de TPV/Facturación.
- [ ] Seleccionar la(s) solución(es) de TPV/Facturación más adecuadas para el mercado español y la escalabilidad de HairConnect.
- [ ] Crear un roadmap detallado para la implementación de la integración TPV/Facturación (fases, estimaciones).

**4. Definición Roadmap Producto V2 (Responsable: CEO, CTO)**
- [ ] Recopilar feedback de todos los sprints anteriores y de los salones piloto.
- [ ] Priorizar funcionalidades y mejoras para la próxima gran versión del producto (V2).
- [ ] Definir los objetivos estratégicos y de negocio para V2.
- [ ] Crear un documento de visión del producto V2 y desglozarlo en épicas de alto nivel.

**5. Seguridad, Rendimiento y Cumplimiento (Responsable: CTO, CEO)**
- [ ] Realizar una revisión de seguridad interna de los flujos de pago y suscripción.
- [ ] Optimizar consultas y estructuras de datos para soportar un mayor volumen de usuarios y transacciones.
- [ ] Asegurar que las políticas de privacidad y consentimiento estén actualizadas conforme a RGPD.
- [ ] Preparar la infraestructura para el aumento de carga esperado con la expansión.

**6. Documentación y Preparación (Responsable: CEO, CTO)**
- [ ] Actualizar la documentación técnica (`Architecture.md`, `Data_Model.md`) con los cambios de monetización y estructura.
- [ ] Crear Sprint7_Review.md documentando decisiones, feedback, KPIs y plan para Sprint 8.
- [ ] Preparar el plan de pruebas y casos de uso para Sprint 7.

## Criterios de Aceptación de Sprint 7

*   **Monetización y Pagos Implementados**
    - [ ] Planes de suscripción configurados y visibles en la plataforma.
    - [ ] Integración funcional con al menos una pasarela de pago (ej. Stripe).
    - [ ] Usuarios pueden suscribirse, pagar y gestionar sus suscripciones (altas, bajas).
    - [ ] Sistema genera facturas básicas y notificaciones de pago.

*   **Expansión Geográfica**
    - [ ] Materiales de marketing y onboarding adaptados para una nueva ciudad.
    - [ ] Se ha completado la investigación de mercado para la ciudad objetivo.
    - [ ] La infraestructura técnica puede soportar futuras localizaciones geo-dependientes.

*   **Consolidación TPV/Facturación y Roadmap V2**
    - [ ] Informe detallado del PoC TPV/Facturación con requisitos técnicos y plan de implementación.
    - [ ] Roadmap de producto V2 definido y priorizado.

*   **Seguridad y Cumplimiento RGPD**
    - [ ] Revisión de seguridad de los flujos de pago y suscripción completada.
    - [ ] Cumplimiento RGPD verificado para los nuevos procesos (consentimiento, políticas de privacidad).

## Riesgos y Mitigaciones

*   **Riesgo:** Complejidad en la integración de pasarelas de pago y gestión de suscripciones.
    *   **Mitigación:** Utilizar SDKs y APIs bien documentadas; empezar con una pasarela principal.
*   **Riesgo:** Dificultad para penetrar en un nuevo mercado geográfico sin experiencia previa.
    *   **Mitigación:** Investigación de mercado detallada y enfoque en una ciudad piloto inicial.
*   **Riesgo:** Retrasos en la definición del roadmap V2 o en la planificación TPV.
    *   **Mitigación:** Dedicar tiempo específico para estas tareas y asegurar la alineación del equipo.
*   **Costos de Infraestructura:** El aumento del volumen y la expansión puede incrementar costos en Firebase.
    *   **Mitigación:** Monitoreo constante de uso y optimización de recursos; planificar estrategias de escalado de costos.

## Priorización de Tareas (Estimada)

1.  Implementación de Monetización y Pagos (CTO)
2.  Definición Roadmap V2 y Plan TPV (CEO, CTO)
3.  Preparación Expansión Geográfica (CMO)
4.  Seguridad, Rendimiento y Cumplimiento (CTO, CEO)
5.  Documentación (CEO, CTO)

**Fin Sprint 7 Backlog.**
