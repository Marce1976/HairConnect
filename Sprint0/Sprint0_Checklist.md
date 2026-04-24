# Sprint 0 Checklists - Preparación y Configuración

Objetivo: dejar el entorno preparado para iniciar el desarrollo del MVP con Flutter + Firebase y establecer las bases de seguridad y datos.

- [ ] Repositorio organizado con estructura de carpetas: client/, salon_panel/, shared/, backend/
- [ ] README actualizado con pautas de desarrollo y convenciones
- [ ] Archivo .gitignore configurado para Flutter, Firebase y herramientas de desarrollo
- [ ] Proyecto Firebase HairConnect creado
  - [ ] Auth (correo/Google) habilitado
  - [ ] Firestore habilitado
  - [ ] Reglas de seguridad básicas definidas
  - [ ] Storage configurado (para imágenes/galería)
- [ ] Proyectos Flutter creados para cliente y panel
- [ ] Paquetes base añadidos en el proyecto Flutter:
  - firebase_core, firebase_auth, cloud_firestore, firebase_storage
- [ ] Archivos de configuración de plataformas integrados:
  - google-services.json (Android)
  - GoogleService-Info.plist (iOS)
- [ ] Arquitectura y modelos de datos documentados
  - [ ] docs/Architecture.md
  - [ ] docs/Data_Model.md
- [ ] Entorno de desarrollo preparado
  - [ ] Guía de instalación de Flutter, Dart, IDEs (VS Code/Android Studio)
  - [ ] Emuladores/simuladores configurados para pruebas
- [ ] CI/CD y pipelines (opcional para Sprint 0)
  - [ ] Propuesta mínima de pipeline local (lint, pruebas simples)
  - [ ] Plan de CI para futuros Sprints
- [ ] Criterios de aceptación de Sprint 0 definidos
- [ ] Plan para Sprint 1 preparado (backlog y prioridades)

Notas:
- Mantener la documentación en docs/ para facilitar consultas y futuras referencias.
- Priorizar la seguridad de Firestore y la estructura de datos desde el inicio para evitar re-trabajo.

Fin Sprint 0. Preparados para avanzar a Sprint 1: Autenticación y datos básicos.