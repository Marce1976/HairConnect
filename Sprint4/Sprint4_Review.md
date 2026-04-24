# Sprint 4 - Revisión (Sprint Review)

Fecha: [Fecha actual]
Participantes: CTO, CMO, CEO

## 1. Resumen de ejecución
- Objetivo del sprint: ampliar el programa piloto a 3-4 salones en Vigo, implementar una versión inicial de fidelización, mejorar el panel de negocio y explorar la integración con sistemas de facturación/TPV, preparando escalabilidad.
- Entregables y resultados: se activaron 3 salones piloto, se avanzó en fidelización (puntos y promociones), se mejoró el panel de negocio con KPIs y notificaciones; se ejecutó la planificación de Sprint 5 y se documentaron los cambios en docs/.

## 2. Decisiones clave
- Continuar con la estrategia de fidelización V1 integrada en el flujo de reserva y en el panel de negocio.
- Mantener la arquitectura Flutter + Firebase para escalabilidad y sincronización en tiempo real.
- Prototipar la integración con TPV/Facturación a nivel conceptual y preparar un plan de implementación futura.
- Consolidar la expansión de pilotos a 3-4 salones y estandarizar onboarding y soporte.

## 3. KPIs y rendimiento
- Salones activos en piloto: 3-4 (objetivo alcanzado).
- Adopción de fidelización: % de usuarios que interactúan con puntos y promociones.
- Panel de negocio: disponibilidad de KPIs clave (ingresos, ocupación, valoraciones).
- Latencia de sincronización: 0 latencia perceptible en reservas entre cliente y salón.
- Bugs críticos reportados y tiempos de resolución: monitorizados; acciones correctivas definidas.

## 4. Riesgos y mitigaciones
- Onboarding de nuevos salones: mitigación con guías rápidas, videos y soporte dedicado.
- Aumento de costos en Firebase por mayor volumen: mitigación con optimización de consultas y monitoreo de uso.
- Integración TPV/Facturación: mitigación mediante PoC y documentación de requisitos para una implementación futura.
- RGPD y seguridad: auditoría de reglas y políticas actualizadas; control de consentimiento.

## 5. Lecciones aprendidas
- El onboarding de salones debe ser muy claro y acompañado; sesiones cortas y material de apoyo aceleran la adopción.
- Fidelización está generando interés; se deben definir reglas más estrictas para evitar abusos y asegurar consistencia.
- La carga de datos y las consultas en Firestore requieren indexing y reglas claras para mantener rendimiento.

## 6. Plan para Sprint 5 (alto nivel)
- Objetivos: ampliar pilotos a 4-5 salones, consolidar fidelización, lanzar informe de KPIs para tomadores de decisión, y comenzar plan de monetización.
- Backlog de alto nivel:
  - Onboarding avanzado de salones y soporte continuo.
  - Ampliar fidelización (promociones, retención) y validación de promociones.
  - Mejoras en panel de negocio y notificaciones personalizables.
  - Pruebas de seguridad y rendimiento bajo mayor carga.
  - Boceto de plan de facturación/TPV y estimaciones de esfuerzo.

## 7. Anexos
- Documentación relevante: Sprint4_Backlog.md, Sprint4_TestPlan.md, Sprint4_Overview.md; cambios en Architecture/Data_Model.md.

Fin Sprint 4 Review.
