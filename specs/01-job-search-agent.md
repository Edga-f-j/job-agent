---
id: 01-job-search-agent
title: Agente de búsqueda y evaluación de ofertas de empleo
state: Draft
date: 2026-06-15
dependencies: ninguna
---

**Objetivo:** Construir un agente conversacional en Claude Code que, dado el CV del
usuario en Markdown o PDF, busque ofertas de empleo en fuentes configurables, evalúe el fit
de cada oferta con el perfil extraído, y mantenga un tracker local en JSON con los
estados del proceso de postulación.

---

## Scope

### Dentro de esta spec
- Lectura y parseo del CV en formato Markdown o PDF al inicio de cada sesión
  - Markdown: lectura directa
  - PDF: extracción de texto con pdfplumber
- Extracción de perfil estructurado del CV (skills, experiencia, títulos, industrias)
- Búsqueda de ofertas en fuentes configurables (defaults: LinkedIn, Indeed, Computrabajo, TuEmpleo, ticjob.co)
- Parámetros de búsqueda definidos en archivo de config, con posibilidad de ajuste por el usuario en sesión
- Filtros de geografía configurables (ciudad, modalidad, idioma)
- Evaluación de cada oferta: nivel de fit (Alto/Medio/Bajo) + fortalezas, brechas, sugerencias
- Deduplicación de ofertas que aparezcan en múltiples fuentes
- Tracker local en JSON con estados: Nueva → Revisada → Postulado → En proceso → Rechazado / Oferta / Descartada
- Todos los estados son configurables por el usuario

### Fuera de esta spec
- Postulación automática a ofertas
- Generación de carta de presentación personalizada
- Notificaciones (email, Slack, u otros canales)
- Soporte para CV en formato LaTeX/Overleaf
- Detección automática de cambios en el CV entre sesiones
- Interfaz web o CLI separado — la interfaz es Claude Code

---

## Modelo de datos

### config.json
Archivo de configuración editable por el usuario.

```json
{
  "cv_path": "cv.md",        // acepta .md o .pdf
  "sources": ["linkedin", "indeed", "computrabajo", "tuempleo", "ticjob"],
  "search": {
    "roles": ["desarrollador backend", "software engineer"],
    "locations": ["Bucaramanga", "Bogotá"],
    "modalities": ["presencial", "híbrido", "remoto"],
    "remote_international": true,
    "languages": ["es", "en"]
  },
  "fit_states": ["Nueva", "Revisada", "Postulado", "En proceso", "Rechazado", "Oferta", "Descartada"]
}
```

### profile.json (generado en sesión, no persistido)
Perfil estructurado extraído del CV por Claude al inicio de la sesión.

```json
{
  "name": "string",
  "titles": ["string"],
  "skills": ["string"],
  "years_experience": "number",
  "industries": ["string"],
  "languages": ["string"],
  "education": ["string"]
}
```

### tracker.json
Registro persistente de todas las ofertas encontradas.

```json
[
  {
    "id": "uuid",
    "title": "string",
    "company": "string",
    "source": "string",
    "url": "string",
    "date_found": "YYYY-MM-DD",
    "location": "string",
    "modality": "presencial | híbrido | remoto",
    "fit_level": "Alto | Medio | Bajo",
    "description_raw": "string",
    "evaluation": {
      "strengths": ["string"],
      "gaps": ["string"],
      "suggestions": ["string"]
    },
    "status": "Nueva | Revisada | Postulado | En proceso | Rechazado | Oferta | Descartada",
    "notes": "string"
  }
]
```

---

## Plan de implementación

Cada paso deja el sistema en un estado funcional y verificable.

1. **Estructura del proyecto**
   Crear la carpeta `jobAgent/` con los archivos base:
   - `config.json` (con valores default documentados)
   - `tracker.json` (array vacío `[]`)
   - `cv.md` o `cv.pdf` (el usuario coloca su CV aquí)
   - `data/reportes/` (carpeta donde se guardan los reportes diarios)
   - `CLAUDE.md` con instrucciones del agente para Claude Code

2. **Parseo del CV**
   Implementar `cv_parser.py`:
   - Si `cv_path` termina en `.md`: leer texto directamente
   - Si termina en `.pdf`: extraer texto con `pdfplumber`
   - Devolver texto plano listo para ser procesado por Claude

3. **Extracción de perfil estructurado**
   Al inicio de sesión, Claude lee el texto del CV y produce un `profile.json`
   en memoria (no persistido) con los campos del modelo de datos.
   El perfil se reutiliza en todas las evaluaciones de la sesión.

4. **Archivo de config y parámetros de búsqueda**
   Claude lee `config.json` al inicio de sesión y presenta al usuario
   un resumen de los parámetros activos. El usuario puede confirmarlos
   o ajustarlos antes de lanzar la búsqueda.

5. **Búsqueda de ofertas**
   Claude usa la herramienta `WebSearch` para buscar ofertas en cada
   fuente configurada, combinando roles, ubicaciones y modalidades
   definidas en config. Resultado: lista de ofertas crudas con título,
   empresa, URL y descripción.

6. **Deduplicación**
   Antes de evaluar, filtrar ofertas cuya URL ya exista en `tracker.json`.
   Para duplicados entre fuentes (misma oferta, distinta URL), comparar
   título + empresa + ubicación como clave compuesta.

7. **Evaluación de ofertas**
   Por cada oferta nueva, Claude genera:
   - `fit_level`: Alto / Medio / Bajo
   - `evaluation.strengths`, `evaluation.gaps`, `evaluation.suggestions`
   Usando el perfil estructurado extraído en el paso 3.

8. **Persistencia en tracker**
   Guardar cada oferta evaluada en `tracker.json` con estado inicial `Nueva`
   y el campo `description_raw` con el texto completo de la oferta.

9. **Actualización de estados**
   El usuario puede pedirle a Claude en cualquier momento:
   "marca la oferta X como Postulado" o "descarta la oferta Y".
   Claude actualiza el campo `status` en `tracker.json`.

10. **Resumen de sesión**
    Claude genera `data/reportes/YYYY-MM-DD.md` con la tabla completa de
    ofertas ordenadas por `fit_level` (Alto primero), incluyendo título,
    empresa, fuente, nivel de fit y URL.
    En terminal muestra solo 3-4 líneas:
    - Total de ofertas encontradas
    - Desglose por fit (Alto: N / Medio: N / Bajo: N)
    - Ruta del reporte generado

---

## Criterios de aceptación

- [ ] Al iniciar sesión, Claude lee `config.json` y muestra un resumen de los parámetros activos
- [ ] Claude parsea correctamente un CV en `.md` y uno en `.pdf` (texto extraído sin errores)
- [ ] Claude extrae un perfil estructurado del CV con al menos: skills, títulos, años de experiencia, idiomas
- [ ] Claude busca ofertas en las 5 fuentes configuradas usando `WebSearch`
- [ ] Las ofertas ya presentes en `tracker.json` no se vuelven a evaluar ni a guardar
- [ ] Si dos fuentes distintas traen la misma oferta (mismo título + empresa + ubicación), se guarda una sola vez en `tracker.json`
- [ ] Cada oferta nueva recibe un `fit_level` (Alto/Medio/Bajo) y una evaluación con strengths, gaps y suggestions
- [ ] Cada oferta evaluada se guarda en `tracker.json` con estado `Nueva` y `description_raw` poblado
- [ ] El usuario puede cambiar el estado de una oferta diciéndole a Claude el cambio, y `tracker.json` se actualiza
- [ ] Se genera `data/reportes/YYYY-MM-DD.md` con la tabla completa ordenada por fit_level
- [ ] En terminal aparece solo el resumen de 3-4 líneas (total, desglose por fit, ruta del reporte)
- [ ] Si se corre la búsqueda dos veces el mismo día, el reporte del día se sobreescribe (no se duplica)

---

## Decisiones tomadas y descartadas

**Formato de CV: Markdown y PDF (no LaTeX)**
Overleaf/LaTeX quedó fuera por complejidad de parseo. Markdown es la fuente principal;
PDF se soporta vía pdfplumber para usuarios que solo tienen el CV exportado.

**Interfaz: Claude Code conversacional (no CLI separado)**
Se descartó construir un CLI Python independiente. La interfaz es Claude Code directamente —
más natural, sin código de scaffolding extra, y el usuario ya trabaja en esa terminal.

**Búsqueda vía WebSearch de Claude (no scraping directo)**
Se descartó playwright/selenium por fragilidad ante cambios de layout y complejidad de
manejo de sesiones/cookies. WebSearch es más robusto y el LLM ya está en el stack.

**Perfil estructurado en memoria (no persistido)**
Se descartó guardar `profile.json` en disco porque el CV puede cambiar entre sesiones.
Re-extraer al inicio garantiza que el perfil siempre refleja la versión actual del CV.

**Reporte diario en archivo (no tabla en terminal)**
Se descartó mostrar la tabla completa en terminal para evitar ruido. El reporte en
`data/reportes/YYYY-MM-DD.md` es abrirlo en VS Code cuando se necesita detalle.

**Tracker en JSON (no CSV ni Notion/Airtable)**
JSON es legible por el agente en sesiones futuras sin parsing especial, y exportable
a cualquier otro formato después. Se descartaron herramientas externas para mantener
todo local y sin dependencias de APIs de terceros.

**Estados configurables con set default**
Se adoptó el set: Nueva → Revisada → Postulado → En proceso → Rechazado / Oferta / Descartada.
El estado Descartada fue agregado por el usuario para distinguir ofertas ignoradas
deliberadamente de ofertas en proceso activo.

**Fuera de scope explícito**
Postulación automática, generación de carta de presentación y notificaciones quedan
fuera. El usuario postula manualmente; el agente es un asistente de búsqueda y evaluación,
no un automatizador de postulaciones.

---

## Riesgos identificados

**WebSearch puede no indexar fuentes locales (Computrabajo, TuEmpleo, ticjob.co)**
LinkedIn e Indeed tienen buena cobertura en búsquedas web generales, pero las fuentes
colombianas pueden tener resultados escasos o desactualizados vía WebSearch.
Mitigación: verificar manualmente en la primera sesión cuántas ofertas trae cada fuente;
si alguna falla consistentemente, considerar scraping directo en una spec posterior.

**Calidad de extracción de PDF variable**
pdfplumber funciona bien con PDFs de texto, pero falla con CVs escaneados o con layouts
de columnas complejas. Mitigación: documentar en el README que el CV debe ser un PDF
de texto (no imagen); si la extracción falla, el usuario cae back a Markdown.

**Deduplicación por título + empresa + ubicación es frágil**
Pequeñas variaciones en el nombre de la empresa ("Bancolombia S.A." vs "Bancolombia")
pueden romper la deduplicación. Mitigación: normalizar strings (lowercase, strip espacios)
antes de comparar; aceptar que habrá falsos negativos ocasionales.

**tracker.json crece sin límite**
Con el tiempo el archivo puede volverse grande y lento de leer/escribir en cada sesión.
Mitigación: fuera de scope por ahora — aceptable hasta ~500 ofertas; archivar entradas
antiguas será tema de una spec futura si se necesita.

**Re-evaluación en sesiones futuras depende de description_raw**
Si una oferta se guardó sin `description_raw` (ej. por un error en una sesión temprana),
no se puede re-evaluar. Mitigación: validar que `description_raw` no esté vacío antes
de guardar; si está vacío, registrar advertencia en terminal.
