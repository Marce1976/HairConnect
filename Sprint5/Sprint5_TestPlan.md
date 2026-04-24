# Sprint 5 - Plan de Pruebas (Monetización y Escalabilidad)

## Objetivo General
Validar las funcionalidades extendidas (fidelización, panel de negocio y onboarding de nuevos salones) con un grupo de pilotos más amplio, evaluar el rendimiento y la seguridad ante mayor volumen y preparar la base para monetización y una integración más madura de TPV/Facturación.

## Alcance de las Pruebas
- Entorno: 4-5 salones piloto en Vigo, incluidos salones existentes y nuevos.
- Usuarios: clientes finales de los salones piloto, dueños/empleados de los salones.
- Funcionalidades a Probar:
  - Proceso de onboarding de salones y soporte continuo.
  - Fidelización V1: puntos, promociones y canje.
  - Panel de negocio: KPIs, notificaciones personalizables y reportes de rendimiento.
  - Flujo de reserva, Look & Book y notificaciones.
  - Seguridad y cumplimiento RGPD (políticas y consentimiento).
  - Viabilidad conceptual de la integración TPV/Facturación (PoC).

## Roles y Responsabilidades en las Pruebas
- CTO: diseñar pruebas técnicas, supervisar ejecución y analizar logs de rendimiento.
- CMO: coordinar pilotos, recopilación de feedback cualitativo y validación de UX.
- CEO: supervisar cumplimiento legal, métricas de negocio y gobernanza.
- Pilotos (Salones): uso diario, reporte de errores y feedback de UX/funcionalidad.

## Criterios de Aceptación de las Historias de Usuario (HUs) del Sprint 5
- HU5.1 Onboarding Salones: 3-4 salones activos con onboarding completo y soporte.
- HU5.2 Fidelización: puntos y promociones funcionando; canje observable por clientes.
- HU5.3 Panel de Negocio: KPIs visibles y actualizados; notificaciones configurables.
- HU5.4 TPV/Facturación (Conceptual): informe de requisitos y PoC de integración detallados.
- HU5.5 Rendimiento y Seguridad: rendimiento estable bajo mayor carga, reglas de seguridad actualizadas y RGPD en revisión.

## Casos de Prueba Detallados
| ID Prueba | HU Asociada | Descripción | Pasos | Resultado Esperado | Resultado Actual | Estado |
|-----------|-------------|-------------|-------|---------------------|------------------|--------|
| TP5.1.1 | HU5.1 | Onboarding Salón Nuevo | 1. Salón registra + completa perfil. 2. Se configuran servicios y estilistas. 3. Se verifica acceso a panel y app. | Registro y configuración completados; acceso operativo | | |
| TP5.2.1 | HU5.2 | Atribución de puntos y canje | 1. Cliente realiza reserva. 2. Acumula puntos. 3. Canjea para descuento en nueva reserva. | Puntos acumulados y descuento aplicado correctamente | | |
| TP5.3.1 | HU5.3 | KPIs del Panel | 1. Generar informe de ingresos y ocupación; 2. Ver notificaciones y filtros | KPIs correctos y actualizados | | |
| TP5.4.1 | HU5.4 | PoC TPV/Facturación | 1. Simulación de reserva; 2. Envío a API TPV simulada | Datos enviados correctamente y respuesta simulada exitosa | | |
| TP5.5.1 | HU5.5 | Prueba de Seguridad | 1. Usuario intenta acceso a datos ajenos; 2. Verificación de permisos | Acceso denegado cuando corresponde | | |
| TP5.6.1 | HU5.3 | Prueba de Carga | 1. Simulación de múltiples reservas simultáneas | El sistema maneja concurrencia sin duplicados | | |

## Pruebas de Rendimiento y Seguridad
- Rendimiento: medir tiempos de carga en panel y tiempos de reserva bajo carga simulada.
- Seguridad: auditoría de reglas Firestore, pruebas de acceso entre salones, pruebas de autenticación y autorización.
- RGPD: verificar consentimiento y políticas de privacidad accesibles.

## Métricas Clave de Éxito (Sprint 5)
- Salones activos y onboarding completado.
- Tasa de adopción de fidelización (clientes).
- Precisión de KPIs y consistencia de reportes.
- Rendimiento: latencia de reserva y sincronización bajo carga.
- Eficiencia de onboarding y soporte de pilotos.
- Viabilidad de monetización y requisitos TPV (PoC).

## Flujo de Trabajo para el Piloto
1. Onboarding de salones y carga de datos de prueba.
2. Activación de fidelización y promoción.
3. Pruebas diarias de reserva y sincronización en tiempo real.
4. Recopilación de feedback estructurado.
5. Análisis de métricas y ajustes.
6. Preparación para Sprint 6 y escalabilidad.

## Notas
- Mantener la priorización en fidelización y panel para maximizar valor para salones y clientes durante el piloto.
- Documentar decisiones y cambios en docs/ para trazabilidad.

Fin Sprint 5 Test Plan.
