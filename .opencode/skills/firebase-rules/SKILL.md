# SKILL: Firestore Security Rules
- **Contexto**: Siempre que el usuario pida cambios en la base de datos de HairConnect.
- **Regla de Oro**: Nunca permitas escrituras (`allow write`) sin verificar que el `request.auth != null`.
- **Estructura**: Las citas deben estar en la colección `/appointments/{appointmentId}`.
- **Validación**: Antes de proponer una regla, verifica que el campo `timestamp` sea obligatorio.