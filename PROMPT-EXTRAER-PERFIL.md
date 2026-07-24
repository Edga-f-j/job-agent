# Cómo generar tu `profile.md` a partir de tu hoja de vida

El agente **no necesita tu PDF**. Le sirve mucho más un `profile.md` bien llenado: es texto
plano, corto y con los campos exactos que usa para buscar. Leer un PDF es lento, se rompe si
falta `poppler`, y mete ruido (formato, iconos, saltos de columna).

Tienes dos formas de crearlo. Ambas dan el mismo resultado.

---

## Opción A — Con cualquier IA de chat (ChatGPT, Gemini, Claude…)

La más cómoda si tu hoja de vida está en PDF. **No necesitas instalar nada.**

1. Abre el chat que uses y **adjunta tu hoja de vida** (PDF, Word o el texto pegado).
2. Copia y pega el prompt de abajo, completo, en el mismo mensaje.
3. Copia la respuesta y guárdala como `profile.md` en la raíz de esta carpeta.
4. **Léelo y corrígelo.** La IA se equivoca en el nivel y en el país; esos dos campos deciden
   toda la búsqueda.

### 👇 Prompt para copiar y pegar

````text
Te adjunto mi hoja de vida. Extrae la información clave y devuélvemela EXACTAMENTE en la
plantilla Markdown de abajo, rellenando cada campo entre corchetes.

Reglas:
- Devuelve SOLO el Markdown final, sin explicaciones ni comentarios previos.
- No inventes nada. Si un dato no está en la hoja de vida, escribe "no especificado".
- "Nivel" es el nivel de puesto al que aspiro, no los años que llevo estudiando. Si no tengo
  empleo formal pagado en el área, el nivel es "junior" aunque tenga proyectos o prácticas.
- "Código ISO del país" es alpha-2 en mayúsculas: Colombia CO, Suiza CH, España ES, México MX,
  Argentina AR, Chile CL, Perú PE, Alemania DE, Dinamarca DK, Estados Unidos US.
- En "Categorías de búsqueda" propón 3 o 4 categorías con las palabras clave reales con las que
  se publican esas vacantes en portales de empleo (no nombres de tecnologías sueltas).
- En "Diferenciador" pon algo que sea poco común para mi nivel, si lo hay.
- En "Limitantes conocidas" sé honesto: idiomas por debajo de B2, tecnologías muy pedidas que
  NO tengo, falta de experiencia formal.

Plantilla:

# Perfil del candidato

## Identidad
- **Nombre:** [nombre completo]
- **Ubicación:** [ciudad], [país]
- **Modalidad buscada:** [remoto / híbrido / presencial / indiferente]

## Ubicación de búsqueda
- **País de búsqueda:** [país]
- **Código ISO del país:** [XX]
- **Ciudad para la sección local:** [ciudad]

## Nivel objetivo
- **Nivel:** [trainee / junior / semisenior / senior]
- **Años de experiencia:** [rango]
- **Descartar títulos:** [títulos por encima de mi nivel, ej. Senior, Lead, Staff, Arquitecto]

## Formación
- [título] — [institución] ([años])
- Cambio de carrera, si aplica: [de qué a qué]

## Experiencia
- [puesto] — [empresa u organización] ([fechas]) — [qué hacía, 1 línea]

## Proyectos
- [nombre] — [tecnologías y qué hace, 1 línea]

## Stack técnico
- **Fuerte:** [lo que domino de verdad]
- **Secundario:** [lo que he usado menos]
- **Diferenciador:** [algo poco común para mi nivel]

## Idiomas
- [idioma y nivel MCER si aparece]

## Limitantes conocidas
- [brechas honestas]

## Categorías de búsqueda
- **[Categoría]:** "[keywords]", "[keywords]"
- **[Categoría]:** "[keywords]"
- **[Categoría]:** "[keywords]"

## CV
- **Ruta:** [ruta al PDF si lo guardaste en la carpeta, o "no adjunto"]
````

---

## Opción B — Con el agente de esta carpeta

Si prefieres no salir de OpenCode / Claude Code:

- **Pega el texto de tu hoja de vida** directamente en el chat (ábrela, selecciona todo, copia) y
  di: *"con esto genera mi profile.md"*. Esta es la vía recomendada: funciona siempre.
- **O**, si quieres que lea el PDF, pega la **ruta del archivo** en el prompt. Requiere que el
  runtime pueda leer PDFs; si falta `poppler` (`pdftoppm`), falla y tendrás que usar el texto.

El agente te muestra el resultado para que lo confirmes antes de guardarlo.

---

## Revisa siempre estos cuatro campos

Son los que cambian los resultados de la búsqueda, y los que peor infiere una IA:

| Campo | Por qué importa |
|---|---|
| **País** y **Código ISO** | Deciden qué portales se usan. Computrabajo solo sirve en Colombia |
| **Nivel** | Si dice "semisenior" cuando eres junior, te llena de vacantes a las que no te van a llamar |
| **Descartar títulos** | Es el filtro que elimina los Senior/Lead del resultado |
| **Categorías de búsqueda** | Son literalmente las queries que se mandan a los portales |

## Privacidad

`profile.md` está en `.gitignore`, así que no se sube a ningún repositorio. Pero **un ZIP hecho a
mano sí se lo llevaría**: si le vas a pasar esta carpeta a alguien, borra tu `profile.md` (y
cualquier CV que hayas guardado) antes de comprimirla. Si la carpeta trae scripts de empaquetado
en `tools/`, úsalos: ya excluyen lo personal por ti.
