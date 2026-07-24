# Guía del agente — buscador de empleo

Este espacio de trabajo hace una sola cosa: **buscar ofertas de empleo** en los portales
instalados y presentarlas filtradas por nivel.

## Fuentes de verdad

1. **`profile.md`** — el perfil del candidato: nivel, stack, país, categorías de búsqueda.
   Es la entrada de todo. **No está versionado y puede no existir.**
   Si falta, **no inventes un perfil**: pide los datos y ofrece las vías del paso 3 del
   `README.md` (el prompt de `PROMPT.txt` en una IA de chat, o pegar el texto de la hoja de vida,
   o llenar a mano una copia de `profile.example.md`).
2. **`.claude/skills/job-search/SKILL.md`** — el procedimiento completo: qué portal correr según
   el país, cómo filtrar por nivel y en qué formato entregar. Síguelo tal cual.

## Portales instalados

Bajo `.agents/skills/`, cada uno con su propio `SKILL.md` que documenta sus flags exactos.
**Usa la interfaz documentada de cada portal, no adivines flags.**

| Portal | Cobertura |
|---|---|
| `linkedin-search` | Cualquier país. Es la base, siempre corre |
| `computrabajo-search` | **Solo Colombia** |
| `freehire-search` | Multi-país por faceta `--country` (ISO alpha-2). Solo roles técnicos |

## Compatibilidad de runtime

Funciona igual en **OpenCode** y en **Claude Code**. Ambos descubren el skill desde
`.claude/skills/`. La configuración de OpenCode está en `opencode.json`, que carga `profile.md`
y pre-aprueba las llamadas `bun run .agents/skills/*`.

## Reglas

- **Nunca inventes vacantes.** Solo presenta lo que salió de la salida real de un CLI.
- **Nunca pidas ni aceptes credenciales de LinkedIn.** El acceso automatizado con sesión iniciada
  viola sus términos. Los scrapers solo leen ofertas públicas.
- **No escribas datos personales** en archivos distintos de `profile.md`.
- Si un CLI falla, registra el error y sigue con los demás; no abortes toda la búsqueda.
- Responde conciso.
