# Buscador de empleo con IA

Un agente que busca ofertas de trabajo por ti en LinkedIn, Computrabajo y freehire, las filtra
según tu nivel y te las entrega en tablas con el link para postular.

No necesitas saber programar. Son 4 pasos, unos 15 minutos la primera vez.

---

## Paso 1 — Instalar Bun

Es lo que hace funcionar los buscadores. Abre PowerShell (busca "PowerShell" en el menú inicio) y
pega esto:

```powershell
powershell -c "irm bun.sh/install.ps1 | iex"
```

En Mac o Linux, en la Terminal:

```bash
curl -fsSL https://bun.sh/install | bash
```

**Cierra la ventana y abre una nueva.** Comprueba que quedó bien:

```
bun --version
```

Si responde un número (por ejemplo `1.3.14`), listo.

---

## Paso 2 — Instalar OpenCode

```
npm install -g opencode-ai
```

Si no tienes `npm`, instala [Node.js](https://nodejs.org) primero.

Luego conecta tu cuenta de IA:

```
opencode auth login
```

Elige tu proveedor y sigue las instrucciones. **Usa el modelo más capaz que tengas disponible** —
con modelos pequeños el agente se salta partes del formato.

---

## Paso 3 — Crear tu perfil (OBLIGATORIO)

**Sin este paso el agente no busca nada.** Es a propósito: sin saber tu nivel, tu país y tu stack,
cualquier búsqueda te devolvería basura.

El agente no lee tu hoja de vida en PDF. Trabaja con un archivo llamado **`profile.md`**, que es tu
hoja de vida resumida en texto plano. Se hace una sola vez.

### La forma fácil: que una IA te lo arme

1. Abre **ChatGPT**, **Gemini** o **Claude** en tu navegador.
2. **Adjunta tu hoja de vida** (el PDF, o el Word, o pega el texto).
3. En esta carpeta, abre el archivo **`PROMPT.txt`** con el Bloc de notas.
4. Selecciona todo (**Ctrl + A**), copia (**Ctrl + C**).
5. Pégalo (**Ctrl + V**) en el mismo mensaje donde adjuntaste la hoja de vida, y envía.
6. La IA te devuelve un texto que empieza con `# Perfil del candidato`. **Cópialo completo.**
7. En esta carpeta, crea un archivo nuevo llamado **`profile.md`** y pega ahí ese texto.

> Para crear el archivo en Windows: clic derecho → Nuevo → Documento de texto, y ponle de nombre
> `profile.md` (asegúrate de que no quede como `profile.md.txt` — necesitas tener activada la
> opción "Extensiones de nombre de archivo" en la pestaña Vista del explorador).

### La forma manual

Copia `profile.example.md`, renómbralo a `profile.md` y llénalo tú.

### Revisa estos 4 campos antes de seguir

Son los que deciden los resultados, y los que peor adivina una IA:

| Campo | Por qué importa |
|---|---|
| **País de búsqueda** | Decide en qué portales se busca |
| **Código ISO del país** | Dos letras: Colombia `CO`, Suiza `CH`, España `ES`, México `MX` |
| **Nivel** | Si dice "senior" cuando eres junior, te llenas de vacantes que no te van a dar |
| **Categorías de búsqueda** | Son literalmente lo que se escribe en el buscador del portal |

### Comprobar que quedó bien

```powershell
powershell -ExecutionPolicy Bypass -File revisar-perfil.ps1
```

Te dice si falta algo antes de que pierdas tiempo buscando.

---

## Paso 4 — Buscar

Abre PowerShell **dentro de esta carpeta** (clic derecho en la carpeta → "Abrir en Terminal") y
escribe:

```
opencode
```

Ya dentro, pide lo que quieras en lenguaje normal:

> dame las ofertas de las últimas 24 horas

Otras cosas que puedes pedir:

- `busca ofertas de los últimos 7 días`
- `solo backend`
- `busca solo en LinkedIn`
- `muéstrame solo las de mi ciudad`

Vas a recibir tablas por categoría con: puesto, empresa, fecha y link. Con 🔥 las publicadas hoy y
⭐ la que mejor encaja contigo.

---

## Cosas que conviene saber

**El filtro de tiempo va por días, mínimo 1 (24 horas).** No existe "últimas 6 horas": los
portales publican la fecha por día, no por hora.

**Qué portal se usa según tu país** (el agente lo decide solo, leyendo tu `profile.md`):

| Tu país | Portales |
|---|---|
| Colombia | LinkedIn + Computrabajo + freehire |
| Cualquier otro | LinkedIn + freehire |

- **Computrabajo solo funciona en Colombia.**
- **freehire** cubre muchos países pero solo puestos técnicos (software, datos, DevOps, ML).
- **LinkedIn** funciona en todos lados.

**Nunca le des tu usuario y contraseña de LinkedIn al agente**, ni a nadie. No los necesita: solo
lee ofertas públicas. Entrar de forma automatizada con tu sesión viola las reglas de LinkedIn y te
pueden bloquear la cuenta.

**Tu `profile.md` es tuyo.** Si le pasas esta carpeta a otra persona, **bórralo antes** — tiene tus
datos personales.

---

## Si algo falla

| Lo que ves | Qué pasa |
|---|---|
| `bun: command not found` | No cerraste y abriste la terminal después de instalar Bun |
| El agente pregunta quién eres | Falta `profile.md`, o está en otra carpeta |
| Salen ofertas de otro país | El país o el código ISO están mal en `profile.md` |
| Salen 0 ofertas | La búsqueda fue muy específica o el rango muy corto. Pide 7 o 30 días |
| La empresa aparece como "—" | Es una vacante confidencial de Computrabajo. Es normal |
| Solo salen puestos senior | Pasa en algunos perfiles; el agente los descarta y te dice cuántos |

Si nada de esto lo arregla, pídele ayuda al propio agente: cuéntale el error tal cual te salió.
