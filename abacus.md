# Reglas de Integración con AbacusAI

Este archivo contiene las directrices obligatorias para el uso de los modelos de AbacusAI por parte del agente asistente.

## Instrucciones Principales
- **Herramienta a utilizar:** Debes utilizar la herramienta `call_mcp_tool`.
- **Servidor MCP:** `abacusai`.
- **Acción:** `chat`.
- **Selección de Modelo:** SIEMPRE debes usar el modelo automático (`auto` o `route-llm`) para delegar la selección del mejor modelo subyacente según la complejidad de la tarea. No selecciones modelos específicos manualmente a menos que el usuario lo solicite explícitamente.
