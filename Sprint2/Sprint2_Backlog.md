# Sprint 2 - Backlog (Reserva, Calendario y Look & Book)

## Objetivo
Implementar el flujo de reserva end-to-end entre cliente y salón, activar el calendario básico para el panel de negocio y habilitar el feed visual Look & Book para iniciar reservas desde imágenes.

## Alcance
- Autenticación ya disponible (cliente y salón).
- Modelos de datos en Firestore: salons, stylists, services, clients, bookings.
- Interfaces iniciales: búsqueda de salones, detalle de salón y servicios, flujo de reserva.
- Calendario básico en el panel de negocio y visualización de citas en tiempo real.
- Integración del feed visual Look & Book con capacidad de reserva desde la imagen.

## Historias de usuario principales
- HU2.1 Como cliente, quiero buscar salones y servicios, seleccionar una franja horaria y reservar una cita.
- HU2.2 Como salón, quiero ver y gestionar mis citas del día/semana y actualizar servicios/horarios.
- HU2.3 Como usuario, quiero reservar desde la galería Look & Book (reserva rápida desde la imagen).

## Entregables
- Flujo de reserva end-to-end en cliente y salón.
- Calendario básico para el panel del salón (día/semana).
- Feed Look & Book funcional con capacidad de reserva desde una imagen.
- Sincronización en tiempo real de reservas entre cliente y salón.
- Reglas de seguridad y acceso en Firestore para roles.

## Backlog y tareas (Sprint 2)
- Cliente App
  - [ ] Implementar pantalla de búsqueda de salones con filtros (ubicación, servicios).
  - [ ] Crear pantalla de detalle del salón con fotos, servicios y disponibilidad.
  - [ ] Implementar flujo de reserva: seleccionar servicio, estilista, fecha y hora; confirmar reserva.
  - [ ] Conectar flujo de reserva con Firestore para crear un booking.
  - [ ] Implementar feed Look & Book: ver imágenes de salones y reservar desde la imagen.
- Salón Panel
  - [ ] Crear vista de calendario diaria/semanal con citas.
  - [ ] CRUD de servicios y estilistas; asignación de horarios.
  - [ ] Ver/gestionar reservas en tiempo real (actualizaciones de otros usuarios).
- Sincronización en tiempo real
  - [ ] Configurar listeners de Firestore para bookings en cliente y salón.
  - [ ] Pruebas de sincronización entre dos salones piloto.
- Arquitectura y datos
  - [ ] Actualizar docs/Data_Model.md con flujos de reserva y estados de bookings.
  - [ ] Dibujar diagrama de flujo de reserva y de interacción cliente-salón.
- Entorno y pruebas
  - [ ] Configurar entorno de pruebas con datos de prueba (salons, servicios, usuarios).
  - [ ] Pruebas de extremo a extremo para el flujo de reserva.
- Documentación
  - [ ] Actualizar Architecture.md con arquitectura de la solución y puntos de integración.
  - [ ] Preparar guía rápida de usuario para pilotos.

## Criterios de aceptación
- Flujo de reserva correcto desde cliente hasta la creación de booking en Firestore y reflejado en tiempo real para cliente y salón.
- Calendario del salón funcional y visible.
- Feed Look & Book muestra al menos un salón con capacidad de reserva desde la imagen.
- Reglas de seguridad en Firestore permiten acceso correspondiente a cada rol.
- Documentación de datos y flujo de reserva disponible en docs/.

## Riesgos y mitigaciones
- Riesgo: Latencia o conflictos de concurrencia en reservas en tiempo real.
  Mitigación: Pruebas en 2 salones piloto, consultas atómicas para bookings y manejo de estados.
- Riesgo: Complejidad de la UI Look & Book.
  Mitigación: Prototipar en Figma y validar con usuarios de prueba previamente.
- Riesgo: Desalineación entre frontend y backend en el modelo de datos.
  Mitigación: Actualizar y validar documentos de Data Model y flujos en reuniones cortas.

## Plan de entrega
- Semana 1: Implementar autenticación y estructuras de datos necesarias; empezar pantallas de búsqueda y detalle.
- Semana 2: Implementar flujo de reserva, sincronización en tiempo real y feed Look & Book; pruebas de extremo a extremo; validar con pilotos.

## Notas
- Este sprint asume que Sprint 1 ya dejó funcionando la autenticación y estructura básica de datos.
- Priorizar la calidad de la experiencia de reserva y la consistencia de datos en tiempo real para el MVP.

```