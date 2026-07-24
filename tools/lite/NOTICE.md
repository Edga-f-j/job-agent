# Atribución

Este paquete es una **versión reducida** del proyecto de código abierto:

> **ai-job-search** — https://github.com/MadsLorentzen/ai-job-search
> Copyright (c) 2026 Mads Lorentzen — Licencia MIT (ver `LICENSE`)

Se distribuye bajo los términos de la licencia MIT, que se conserva íntegra en el archivo
`LICENSE`.

## Qué cambia respecto al original

**Se quitó** todo lo que no interviene en la búsqueda de ofertas: las plantillas LaTeX de CV y
cartas de presentación, los comandos `/apply`, `/setup`, `/rank` e `/interview` (que además solo
funcionan en Claude Code), la herramienta de salarios, los tests, y los cuatro buscadores de
portales daneses.

**Se añadió:**
- `computrabajo-search` — buscador de Computrabajo Colombia, en el mismo formato de skill que los
  demás portales.
- `.claude/skills/job-search/` — procedimiento de búsqueda con enrutado de portal según el país
  del candidato.
- `profile.md` como perfil en texto plano, en lugar de leer un CV en PDF.
- `PROMPT.txt` / `PROMPT-EXTRAER-PERFIL.md` — para generar ese perfil desde una hoja de vida con
  cualquier IA de chat.
- `opencode.json` y soporte documentado para [OpenCode](https://opencode.ai).

Si quieres el proyecto completo —incluido el armado automático de CV y cartas a la medida de cada
vacante— consíguelo en el repositorio original enlazado arriba.
