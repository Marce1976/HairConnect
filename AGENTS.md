# HairConnect — Contexto del Proyecto

## Stack
- Flutter + Dart
- Firebase Auth + Firestore
- Clean Architecture
- BLoC para gestión de estado
- GoRouter para navegación

## Estructura
- `lib/features/*/presentation/` → pantallas, widgets y blocs por feature
- `lib/features/*/presentation/bloc/` → BLoCs específicos de cada feature
- `lib/core/routes/` → configuración de GoRouter
- `lib/core/errors/` → jerarquía tipada de Failures
- `lib/core/theme/` → colores y estilos centralizados (AppColors)
- `lib/core/` → servicios compartidos, repositorios
- `functions/` → Cloud Functions (si aplica)

## Decisiones arquitectónicas
- **GoRouter**: navegación declarativa con rutas anidadas, ShellRoute para tabs del negocio, y redirects basados en rol.
- **BLoC**: gestión de estado con eventos y estados tipados. Separación clara en `bloc/` dentro de cada feature.
- **Firebase Auth + Firestore**: autenticación con email/contraseña y persistencia en Firestore. El rol (`client` / `business`) se almacena en un documento `users/{uid}`.
- **Failures tipados**: los errores se modelan como una jerarquía de clases en `core/errors/` (ej. `AuthFailure`, `FirestoreFailure`) para ser manejados de forma predecible en la UI.

## Convenciones
- Conventional commits (feat:, fix:, chore:)
- Una feature por rama
- NUNCA credenciales en el código

## Comandos clave
- flutter pub get
- flutter analyze
- flutter test
