# Arranque rápido — buscar empleo con OpenCode

Guía para quien recibió esta carpeta comprimida. Solo cubre la **búsqueda de ofertas**.
Si además quieres el armado de CV y cartas de presentación en LaTeX, eso solo funciona en
Claude Code: mira `SETUP.md`.

Tiempo estimado: 10 minutos.

---

## 1. Instalar Bun

Los scrapers están en TypeScript y corren con [Bun](https://bun.sh).

```powershell
# Windows
powershell -c "irm bun.sh/install.ps1 | iex"
```
```bash
# macOS / Linux
curl -fsSL https://bun.sh/install | bash
```

Verifica con `bun --version`. Si el comando no existe, cierra y vuelve a abrir la terminal.

## 2. Instalar OpenCode

```bash
npm install -g opencode-ai
```
Otras opciones (Homebrew, script de instalación) en <https://opencode.ai/docs>.

Luego configura tu proveedor de modelo con `opencode auth login`. Sirve cualquier modelo
capaz de seguir instrucciones largas; con modelos pequeños el formato de salida se degrada.

## 3. Crear tu perfil — este es el paso importante

El agente trabaja con `profile.md`, **no con tu PDF**. Es texto plano con los campos exactos que
necesita para buscar: se lee rápido, no depende de librerías de PDF y no mete ruido de formato.

La forma más cómoda de armarlo, si tu hoja de vida está en PDF:

> Abre ChatGPT / Gemini / Claude, **adjunta tu hoja de vida**, y pégale el prompt que está en
> **[PROMPT-EXTRAER-PERFIL.md](PROMPT-EXTRAER-PERFIL.md)**. Guarda la respuesta como `profile.md`
> en esta carpeta.

Alternativas: copiar `profile.example.md` a `profile.md` y llenarlo a mano, o pegarle el texto de
tu hoja de vida al agente y pedirle *"genera mi profile.md"*.

Sea cual sea la vía, **revisa estos campos antes de buscar** — son los que deciden los resultados
y los que peor infiere una IA:

- **País de búsqueda** — lo usa LinkedIn (`-l "Colombia"`, `-l "Switzerland"`, …)
- **Código ISO del país** — alpha-2, lo usa freehire (`CO`, `CH`, `ES`, `MX`, `DE`…)
- **Nivel** y **Descartar títulos** — si el nivel queda inflado, te llenas de vacantes senior
- **Categorías de búsqueda** — son literalmente las queries que se mandan a los portales

`profile.md` no se comparte: está en `.gitignore` y el script de empaquetado lo excluye.

## 4. Tu CV en PDF (opcional)

No hace falta para buscar. Guárdalo en `documents/cv/` solo si quieres tenerlo a mano para
postular o para regenerar el perfil después. Esa carpeta está ignorada por git y excluida del ZIP.

## 5. Buscar

```bash
opencode
```

Y pide, en lenguaje normal:

> dame las ofertas de las últimas 24 horas

También sirve "busca ofertas de los últimos 7 días", "solo backend", "busca en LinkedIn".
El agente carga el skill `job-search`, elige los portales según tu país, corre las búsquedas y
te devuelve tablas por categoría con el link de cada vacante.

Nota sobre el rango de tiempo: el filtro va por **días, mínimo 1 (24h)**. No existe filtro por
horas — las vacantes traen fecha de día, no de hora.

---

## Qué portal se usa según tu país

| Tu país | Portales |
|---|---|
| Colombia | LinkedIn + Computrabajo + freehire |
| Suiza / España / Alemania / cualquier otro | LinkedIn + freehire |
| Dinamarca | LinkedIn + los 4 portales daneses (hay que reactivarlos) |

- **Computrabajo es solo Colombia.** Fuera de ahí no devuelve nada útil.
- **freehire** cubre muchos países pero solo roles técnicos (software, datos, DevOps, ML).
- Los 4 portales daneses vienen **desactivados** (`enabled: false` en su `SKILL.md`). Si buscas
  en Dinamarca, cámbialos a `enabled: true`.

## Opcional: poppler, solo si quieres que el agente lea PDFs

**No lo necesitas** si armaste tu `profile.md` como dice el paso 3. Solo hace falta si le vas a
pedir al agente que lea un PDF directamente; sin esto falla con `pdftoppm is not installed`.

```powershell
winget install --id oschwartz10612.Poppler   # Windows
```
```bash
brew install poppler                          # macOS
sudo apt-get install poppler-utils            # Debian / Ubuntu
```

Alternativa sin instalar nada: **pega la ruta del PDF en el prompt** — así el archivo se adjunta
directo y el agente lo lee igual.

---

## Reglas

- **Nunca le des tus credenciales de LinkedIn al agente**, ni se las pidas. El acceso automatizado
  con sesión iniciada viola los términos de LinkedIn y te pueden banear la cuenta. Los scrapers
  solo leen vacantes públicas del portal.
- El agente lee vacantes **formales** del portal, no posts del feed de reclutadores.
- Si vas a pasarle esta carpeta a alguien más, **no la comprimas a mano**: usa
  `tools/pack-share.ps1` (o `tools/pack-share.sh`). Un ZIP normal ignora el `.gitignore` y se
  llevaría tu `profile.md` y tu CV adentro.

## Problemas comunes

| Síntoma | Causa |
|---|---|
| `bun: command not found` | Bun no está en el PATH — reabre la terminal |
| 0 resultados | Query muy larga o específica + rango corto. Acorta la query o sube a 7/30 días |
| Vacantes de otro país | Falta el país en `profile.md`, o el ISO está mal |
| Empresa aparece como "—" | Vacante confidencial en Computrabajo. No es un error |
| Solo salen puestos senior | Normal en algunos stacks; el agente los descarta y te dice cuántos |
