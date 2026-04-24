# Sprint 6 - Plan de Pruebas (Monetización y Expansión)

## Objetivo General
Validar el lanzamiento del plan de monetización, las bases para la expansión geográfica y la viabilidad de la integración con TPV/Facturación. Asegurar la robustez del sistema y el cumplimiento normativo.

## Alcance de las Pruebas
- **Entorno:** Entorno de Staging/Producción (controlado) para pruebas de pago y suscripción; entorno de desarrollo para TPV/Facturación PoC y Roadmap V2.
- **Usuarios:** Equipo interno (para pruebas de pago, suscripción, admin), un grupo selecto de salones piloto (para validación de suscripción y expansión).
- **Funcionalidades a Probar:**
  - Flujo de suscripción y pago (seleccion de plan, pasarela de pago).
  - Gestión de suscripción (altas, bajas, actualizaciones, facturas).
  - Preparación para expansión (infraestructura, materiales de marketing).
  - Viabilidad conceptual de integración TPV/Facturación (evaluación de PoC).
  - Roadmap V2 y estrategia financiera.
  - Seguridad de los flujos de pago y datos del cliente.
  - Cumplimiento RGPD en los nuevos procesos.

## Criterios de Aceptación de las HUs del Sprint 6

*   **HU6.1: Monetización y Pagos Implementados**
    *   [ ] Planes de suscripción configurados y visibles en la plataforma.
    *   [ ] Integración funcional con al menos una pasarela de pago (ej. Stripe).
    *   [ ] Usuarios pueden suscribirse, pagar y gestionar sus suscripciones (altas, bajas).
    *   [ ] Sistema genera facturas básicas y notificaciones de pago.

*   **HU6.2: Preparación para Expansión Geográfica**
    *   [ ] Materiales de marketing y onboarding adaptados para una nueva ciudad.
    *   [ ] Se ha completado la investigación de mercado para la ciudad objetivo.
    *   [ ] La infraestructura técnica puede soportar futuras localizaciones geo-dependientes.

*   **HU6.3: Consolidación TPV/Facturación y Roadmap V2**
    *   [ ] Informe detallado del PoC TPV/Facturación con requisitos técnicos y plan de implementación.
    *   [ ] Roadmap de producto V2 definido y priorizado.

*   **HU6.4: Seguridad y Cumplimiento RGPD**
    *   [ ] Revisión de seguridad de los flujos de pago y suscripción completada.
    *   [ ] Cumplimiento RGPD verificado para los nuevos procesos (consentimiento, políticas de privacidad).

## Casos de Prueba Detallados (Ejemplos)

| ID Prueba | HU Asociada | Descripción de la Prueba | Pasos | Resultado Esperado | Resultado Actual | Estado | Notas |
| :-------: | :----------: | :---------------------------- | :---- | :---------------- | :---------------- | :-----: | :---- |
| TP6.1.1 | HU6.1 | Suscripción Exitosa (Plan Mensual) | 1. Usuario (salón) selecciona plan 'Pro' mensual. 2. Procede a pagar con tarjeta de crédito (test). 3. Confirma pago. | Suscripción creada, pago procesado correctamente, salón recibe notificación, plan activo. | | | |
| TP6.1.2 | HU6.1 | Baja de Suscripción | 1. Suscriptor activo accede a gestionar suscripción. 2. Selecciona cancelar suscripción. 3. Confirma baja. | Suscripción cancelada, acceso mantenido hasta fin de ciclo de facturación, notificación de cancelación. | | | |
| TP6.2.1 | HU6.3 | Revisión Materiales de Expansión | 1. CMO revisa materiales (folletos, web, emails) para nueva ciudad. 2. Validar localización y pertinencia cultural. | Materiales listos y validados para la ciudad objetivo. | | | |
| TP6.4.1 | HU6.4 | Revisión Política de Privacidad | 1. Cliente accede a Política de Privacidad actualizada. | La política es clara, cubre los flujos de pago/suscripción y RGPD. | | | |

## Pruebas de Seguridad y Cumplimiento

*   **Seguridad de Pagos:** Validación de la protección de datos de pago (PCI-DSS compliance si aplica a través de la pasarela), tokenización, prevención de fraude.
*   **Seguridad de Sincronización:** Asegurar que los datos de suscripción y pago no se expongan a otros usuarios.
*   **RGPD:** Verificación del consentimiento explícito para el tratamiento de datos de pago y facturación; política de privacidad actualizada y accesible.

## Métricas Clave de Éxito para Sprint 6

*   Porcentaje de planes de suscripción configurados y activos.
*   Tasa de éxito de pagos (primeras transacciones).
*   Progreso en la preparación de expansión (materiales, estrategia).
*   Viabilidad del plan TPV/Facturación y Roadmap V2 definidos.
*   Cumplimiento de objetivos de seguridad y RGPD.

## Requisitos para Nuevos Salones (Expansión)

*   Análisis de mercado y competencia en la ciudad objetivo.
*   Adaptación de materiales de marketing y comunicación.
*   Definición de estrategia de prospección y primeros contactos.

## Notas

- Este sprint es clave para la sostenibilidad financiera del proyecto.
- La elección de pasarela de pago y la simplificación del flujo de suscripción son críticas.

**Fin Sprint 6 Test Plan.**
