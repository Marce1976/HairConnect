# Sprint 4 - Overview

## Duración
2 semanas

## Objetivo
Ampliar piloto a 3-4 salones en Vigo, reforzar fidelización, mejorar el panel de negocio y sentar bases para la facturación/TPV, preparando escalabilidad.

## Alcance
- Reclutar y activar 3-4 salones en Vigo como pilotos ampliados.
- Implementar una versión inicial de fidelización (puntos, promociones) integrada en el flujo de reserva.
- Mejoras en el panel de negocio: KPI, notificaciones, visualización de datos.
- Explorar integración con sistemas de facturación/TPV para salones (investigación y pruebas conceptuales).
- Seguridad y cumplimiento: revisión RGPD y reglas de Firestore ante mayor volumen.

## Entregables
- Sprint 4 Backlog detallado.
- Prototipo de UX para fidelización y panel (alta prioridad).
- Flujo de reserva estable con fidelización funcionando a modo de pruebas.
- Plan de pruebas de Sprint 4.
- Documento de Arquitectura/Data Model actualizado si hay cambios.
- Informe de progreso para stakeholders.

## Historias de Usuario (HUs) Principales
- HU4.1 Como salón, quiero ampliar mi participación a 3-4 salones y gestionar servicios/horarios.
- HU4.2 Como CTO, quiero optimizar rendimiento de sincronización y UX de fidelización.
- HU4.3 Como CMO, quiero campañas de onboarding y retención para nuevos salones.
- HU4.4 Como CEO, quiero un prototipo de integración de TPV (conceptual) y estimación de costes.

## Criterios de Aceptación
- Al menos 3 salones activos en piloto y feedback recogido.
- Fidelización funcional con pruebas básicas (puntos, promociones).
- Panel de negocio con KPIs operativos y reportes simples.
- Sincronización robusta ante mayor carga.
- RGPD documentado y en revisión.

## Plan de ejecución (estructura)
- Semana 1: Onboarding de nuevos salones, ajustes en UI/UX para fidelización y panel, pruebas de reserva con mayor concurrencia.
- Semana 2: Pruebas de fidelización y panel, evaluación de rendimiento, cierre de backlog de Sprint 4 y preparación para Sprint 5.

## KPIs Propuestos
- Salones activos y tasa de retención.
- Tasa de reservas exitosas.
- Latencia de sincronización y throughput de Firestore.
- Número de incidencias/críticos y tiempo de resolución.
- Utilización de Look & Book y conversión a reservas.
- Cumplimiento RGPD.

## Riesgos y Mitigaciones
- Retrasos por on-boarding de salones; mitigación: guías rápidas, sesiones en vivo.
- Aumento de costos por fidelización; mitigación: pruebas piloto con presupuesto limitado.
- Complejidad técnica de bonos/promo; mitigación: MVP de fidelización simple.
- Riesgo de seguridad con mayor volumen; mitigación: revisión de reglas y auditoría de seguridad.

## Notas
- Este sprint sienta las bases para la monetización y escalado geográfico.