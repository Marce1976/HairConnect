# Sprint 3 - Plan de Pruebas (Piloto)

## Objetivo General
Validar la funcionalidad, usabilidad y robustez del MVP de HairConnect en un entorno real a través de pruebas beta con salones piloto, asegurando la calidad y recogiendo datos para futuras iteraciones.

## Alcance de las Pruebas

-   **Entorno:** Salones piloto en Vigo (2-3 salones)
-   **Usuarios:** Clientes de los salones piloto, dueños/empleados de los salones piloto.
-   **Funcionalidades a Probar:**
    *   Autenticación (registro, login, Google Sign-In).
    *   Flujo de reserva end-to-end (cliente <-> salón).
    *   Visualización y gestión de citas en calendario del salón.
    *   Feed Look & Book y reserva desde imagen.
    *   Gestión de perfil (salón, estilista, servicios).
    *   Notificaciones push (confirmación, recordatorio).
    *   Sistema básico de fidelización (acumulación de puntos).
    *   Funcionalidad web y móvil.

## Roles y Responsabilidades en las Pruebas

*   **CTO:** Diseñar pruebas técnicas, supervisar la corrección de errores críticos, analizar logs.
*   **CMO:** Facilitar la participación de los pilotos, observar el uso, recopilar feedback cualitativo, validar la usabilidad según el público objetivo.
*   **CEO:** Asegurar la trazabilidad de los casos de prueba, validar el cumplimiento RGPD, corroborar métricas de negocio.
*   **Pilotos (Salones):** Utilizar la app/panel de forma regular, reportar errores y sugerencias, proporcionar feedback sobre funcionalidad y UX.

## Criterios de Aceptación de las Historias de Usuario (HUs) del Sprint 3

*   **HU3.1: Entorno de Piloto Estable y Feedback Efectivo**
    *   [ ] 2 salones piloto activos usando la plataforma durante al menos 1 semana.
    *   [ ] Se ha establecido un canal de comunicación bidireccional con los pilotos.
    *   [ ] Se han recogido al menos 5 feedback cualitativos por salón.
    *   [ ] El sistema de reporte de errores funciona y se han procesado los reportes.

*   **HU3.2: Reserva Intuitiva y Notificaciones Fiables**
    *   [ ] Tasa de éxito del flujo de reserva (cliente: búsqueda -> selección -> confirmación) > 90%.
    *   [ ] Tiempo medio de reserva << 3 minutos.
    *   [ ] El 95% de las confirmaciones y recordatorios de citas se envían a tiempo.
    *   [ ] El 80% de los usuarios piloto reportan sentirse 'satisfechos' o 'muy satisfechos' con la usabilidad del flujo.

*   **HU3.3: Look & Book Atractivo y Funcional**
    *   [ ] El 70% de los salones piloto han subido al menos 5 imágenes a su galería.
    *   [ ] El proceso de reserva desde una imagen es un flujo directo y claro.
    *   [ ] Los clientes piloto han realizado al menos 1 reserva desde el feed Look & Book.
    *   [ ] La visualización de imágenes es rápida y sin degradación de calidad.

*   **HU3.4: Código Limpio y Testeable**
    *   [ ] Cobertura de pruebas unitarias > 60% en módulos críticos (reserva, autenticación).
    *   [ ] Al menos 2 pruebas de integración end-to-end funcionales.
    *   [ ] El código del sprint sigue las guías de estilo y convenciones.

## Casos de Prueba (Ejemplos)

| ID Prueba | HU Asociada | Descripción de la Prueba | Pasos | Resultado Esperado | Resultado Actual | Estado (Pasa/Falla) | Notas |
| :-------: | :----------: | :---------------------------- | :---- | :---------------- | :---------------- | :------------------: | :---- |
| TP3.1.1 | HU3.1 | Prueba de Onboarding y Uso Básico | 1. Piloto crea cuenta y perfil salón. 2. Piloto sube servicios/estilistas. 3. Piloto reserva cita con cliente real. | Creación de cuenta y perfil exitosa; reserva creada y visible en panel. | | | |
| TP3.2.1 | HU3.2 | Flujo de Reserva Completo (Cliente) | 1. Cliente busca salón X. 2. Selecciona servicio A, estilista B. 3. Elige hora disponible. 4. Confirma reserva. | Reserva creada en Firestore, notificaciones enviadas, visible en cliente y panel salón. | | | |
| TP3.2.2 | HU3.2 | Conflicto de Disponibilidad | 1. Salón tiene hora Y bloqueada. 2. Cliente intenta reservar en hora Y. | El cliente no debe poder seleccionar hora Y; o se muestra advertencia clara. | | | |
| TP3.2.3 | HU3.2 | Notificación de Recordatorio | 1. Cliente hace reserva con X horas de antelación. 2. Verifica recepción de notificación push. | La notificación se envía en el tiempo configurado (ej. 1 hora antes). | | | |
| TP3.3.1 | HU3.3 | Reserva desde Imagen Look & Book | 1. Cliente ve imagen de peinado en Feed. 2. Toca la imagen. 3. Navega a reserva. 4. Completa reserva. | El flujo de reserva se inicia correctamente desde la imagen; reserva se crea. | | | |
| TP3.4.1 | HU3.4 | Prueba de Integración (Reserva End-to-End) | Ejecución completa del flujo: Cliente reserva -> Salón ve cita -> Salón marca como completada -> Cliente ve historial. | El flujo se completa sin errores y todos los estados se actualizan correctamente. | | | |
| TP3.5.1 | HU3.5 | Reglas de Seguridad (Acceso Salón A a Datos Salón B) | 1. Crear cuenta Salón A y Salón B. 2. Desde Salón A, intentar ver/modificar datos de Salón B. | El acceso debe ser denegado. Solo se pueden ver/modificar datos propios. | | | |
| TP3.6.1 | HU3.6 | RGPD - Política de Privacidad | 1. Cliente accede a política de privacidad desde la app. | El enlace a la política de privacidad funciona y el documento es accesible. | | | |

## Pruebas de Rendimiento y Estabilidad

*   **Carga de imágenes Look & Book:** Medir tiempo de carga inicial y tiempo de carga al desplazarse en galerías grandes.
*   **Sincronización en tiempo real:** Simular alta concurrencia de reservas y modificaciones en el calendario para medir latencia y estabilidad.
*   **Pruebas de estrés:** Ejecutar múltiples reservas simultáneas desde diferentes clientes y paneles para identificar posibles conflictos.

## Pruebas de Seguridad y Cumplimiento (RGPD)

*   **Revisión de Reglas Firestore:** Asegurar que no hay fugas de datos o accesos no autorizados.
*   **Consentimiento:** Verificar que los usuarios dan su consentimiento explícito para el tratamiento de datos y políticas de privacidad.
*   **Acceso a Datos:** Confirmar que un usuario solo puede acceder a sus propios datos (cliente) o a los de su salón.

## Métricas Clave de Éxito para el Piloto

1.  **Tasa de Conversión de Pilotos a Usuarios Activos:** % de salones piloto que continúan usando la plataforma tras la fase de prueba.
2.  **Tasa de Éxito de Reserva:** % de intentos de reserva que se completan satisfactoriamente.
3.  **Tiempo Medio de Reserva:** Duración promedio desde que un cliente inicia la búsqueda hasta que confirma la cita.
4.  **Latencia de Sincronización en Tiempo Real:** Tiempo promedio que tarda una actualización (ej. nueva reserva) en aparecer en el otro extremo (cliente/salón).
5.  **Reporte de Bugs Críticos:** Número de bugs de alta prioridad reportados por los pilotos.
6.  **Feedback Cualitativo:** Puntuación media de satisfacción de usabilidad (escala 1-5).
7.  **Uso de Look & Book:** % de reservas realizadas a través del feed Look & Book vs. reserva directa.

## Flujo de Trabajo para el Piloto

1.  **Configuración Inicial:** Salones piloto reciben acceso, datos de prueba cargados, breve sesión de onboarding.
2.  **Uso Diario:** Pilotos usan la plataforma para sus operaciones diarias.
3.  **Reporte de Feedback:** Pilotos reportan inconsistencias, bugs, sugerencias a través del canal definido.
4.  **Análisis y Corrección:** El equipo revisa el feedback y los logs, prioriza y corrige errores críticos.
5.  **Iteración Rápida:** Se despliegan actualizaciones con correcciones y mejoras basadas en el feedback.
6.  **Evaluación Final:** Al final del sprint, se evalúa el cumplimiento de los casos de prueba y criterios de aceptación, y se recopila feedback de cierre.

**Fin Sprint 3 Test Plan.**
