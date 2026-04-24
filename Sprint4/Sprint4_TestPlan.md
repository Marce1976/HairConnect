# Sprint 4 - Plan de Pruebas (Piloto Ampliado y Funcionalidades Nuevas)

## Objetivo General
Validar las nuevas funcionalidades de fidelización y panel, asegurar la estabilidad con un piloto ampliado y verificar la robustez de la plataforma ante un mayor volumen de datos y usuarios. Evaluar la viabilidad conceptual de integraciones externas.

## Alcance de las Pruebas

*   **Entorno:** 3-4 salones piloto en Vigo (salones existentes y nuevos).
*   **Usuarios:** Usuarios de los salones piloto, clientes finales de estos salones.
*   **Funcionalidades a Probar:**
    *   Proceso de onboarding mejorado para nuevos salones.
    *   Sistema de fidelización V1: acumulación de puntos, visualización, canje por descuentos.
    *   Panel de negocio: KPIs (ingresos, ocupación, valoraciones), notificaciones personalizables, filtros de calendario/citas.
    *   Estabilidad y rendimiento de la plataforma ante mayor concurrencia y volumen de datos.
    *   Seguridad de Firestore y autenticación.
    *   Viabilidad conceptual de la integración TPV/Facturación (si se realizaron PoCs).

## Criterios de Aceptación de las Historias de Usuario (HUs) del Sprint 4

*   **HU4.1: Ampliación de Piloto Exitosa (Salones)**
    *   [ ] 3-4 salones activos y funcionando satisfactoriamente.
    *   [ ] Proceso de onboarding completado para todos los nuevos pilotos.
    *   [ ] El soporte y la comunicación con los pilotos son eficientes.
    *   [ ] Feedback de los salones sobre el proceso de onboarding y uso general.

*   **HU4.2: Fidelización Funcional (V1)**
    *   [ ] El sistema de acumulación de puntos funciona según la lógica definida (ej. 1 punto por cada 1€ gastado).
    *   [ ] Los clientes pueden ver sus puntos acumulados y el historial.
    *   [ ] Los salones pueden definir promociones y los clientes pueden canjear puntos por descuentos en el flujo de reserva.
    *   [ ] La lógica de puntos y canje es consistente y no genera discrepancias en reservas pasadas o futuras.

*   **HU4.3: Panel de Negocio con KPIs y Notificaciones**
    *   [ ] Los KPIs (ingresos, ocupación, valoraciones) se muestran de forma precisa y actualizada.
    *   [ ] Los filtros en calendario y listas de citas funcionan correctamente.
    *   [ ] Las notificaciones personalizables se reciben según las configuraciones del salón.
    *   [ ] El salón puede gestionar y visualizar sus datos de forma intuitiva.

*   **HU4.4: Exploración TPV/Facturación (Conceptual)**
    *   [ ] Se ha producido un informe con análisis de APIs comunes y requisitos técnicos.
    *   [ ] Se han realizado pruebas conceptuales o prototipos de integración (si aplica).
    *   [ ] Se dispone de una estimación de esfuerzo y coste para una futura integración.

*   **HU4.5: Optimización y Seguridad Robusta**
    *   [ ] Pruebas de rendimiento muestran mejora en tiempos de carga y sincronización.
    *   [ ] Reglas de Firestore actualizadas y revisadas para soportar mayor carga sin degradación de seguridad.
    *   [ ] Las pruebas de estrés no revelan fallos críticos.

## Casos de Prueba Detallados

| ID Prueba | HU Asociada | Descripción de la Prueba | Pasos | Resultado Esperado | Resultado Actual | Estado | Notas |
| :-------: | :----------: | :---------------------------- | :---- | :---------------- | :---------------- | :-----: | :---- |
| TP4.1.1 | HU4.1 | Onboarding Nuevo Salón Piloto | 1. Nuevo salón accede a enlace de registro. 2. Completa datos básicos, servicios, estilistas. 3. Recibe bienvenida y guía. | Registro completado; perfil de salón configurado; acceso a funcionalidades básicas. | | | |
| TP4.2.1 | HU4.2 | Acumulación de Puntos por Reserva | 1. Cliente realiza reserva de 50€. 2. Reserva se marca como completada. 3. Verifica saldo de puntos del cliente. | Se añaden los puntos correspondientes (ej. 50 puntos) al saldo del cliente. | | | |
| TP4.2.2 | HU4.2 | Canje de Puntos por Descuento | 1. Cliente tiene X puntos. 2. Inicia reserva y selecciona canjear puntos para obtener Y% de descuento. 3. Confirma reserva. | El descuento se aplica correctamente al precio del servicio; reserva confirmada con precio reducido. | | | |
| TP4.3.1 | HU4.3 | Visualización de KPIs en Panel | 1. Salón accede al panel de negocio. 2. Verifica que los gráficos de ingresos, ocupación y valoraciones se muestran correctamente. | Los datos de los KPIs son precisos y se actualizan según la actividad reciente. | | | |
| TP4.3.2 | HU4.3 | Filtro de Citas por Estado | 1. Salón filtra citas por estado (ej. 'Completada'). 2. Verifica que solo se muestran citas con ese estado. | El filtro funciona y la lista se actualiza correctamente. | | | |
| TP4.4.1 | HU4.4 | Prototipo Integración TPV (Conceptual) | 1. Ejecuta simulación de envío de datos de reserva/cobro a API TPV simulada. | La conexión se establece y los datos son enviados correctamente (dentro del entorno de prueba). | | | |
| TP4.5.1 | HU4.5 | Prueba de Carga - Múltiples Reservas | 1. Simula X clientes realizando reservas simultáneamente en el mismo salón. | El sistema maneja la concurrencia sin crear citas duplicadas ni errores de disponibilidad. | | | |

## Pruebas de Rendimiento y Escalabilidad

*   **Carga de Datos:** Medir tiempos de carga en el panel de negocio con datos de múltiples salones y un año de historial.
*   **Rendimiento de Fidelización:** Validar que la acumulación y canje de puntos son rápidas incluso con miles de clientes y transacciones.
*   **Concurrencia:** Simular picos de actividad (ej. fin de semana, promociones) para medir la capacidad de respuesta del sistema.

## Pruebas de Seguridad y Cumplimiento

*   **Auditoría de Reglas Firestore:** Revisión exhaustiva de reglas para asegurar que no hay accesos no autorizados, especialmente con más datos.
*   **Prueba de Acceso a Datos:** Verificar que los datos de un salón piloto no son accesibles por otro salón, incluso con cuentas de usuario diferentes.
*   **RGPD:** Revisión de la política de privacidad y los mecanismos de consentimiento para los nuevos pilotos y funcionalidades.

## Métricas Clave de Éxito para Sprint 4

*   Número de salones piloto activos y funcionales.
*   Tasa de adopción de la funcionalidad de fidelización por clientes.
*   Precisión y utilidad de los KPIs en el panel de negocio.
*   Calidad y utilidad del informe sobre integración TPV/Facturación.
*   Mejora observable en métricas de rendimiento (tiempos de carga, latencia).
*   Número y severidad de bugs críticos reportados.

**Fin Sprint 4 Test Plan.**
