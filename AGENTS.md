---
framework_version: 1.0.0
---

# Agent Guidelines: AI Job Search

This workspace is structured to manage job search activities, scraper tools, CVs, cover letters, and interview preparation.

## Thin-Pointer Design (Single Source of Truth)

To prevent duplication and configuration drift across different AI agent frameworks (Claude Code, Google Antigravity, Codex, Cursor, Gemini CLI, etc.), this workspace uses a unified thin-pointer design. All agent runtimes should load the canonical specifications and candidate profiles from the files and directories below:

1. **Personal Candidate Profile:**
   - The candidate profile, contact details, education, and target preferences are defined in [CLAUDE.md](CLAUDE.md) and the individual profile methodology files under [.claude/skills/job-application-assistant/](.claude/skills/job-application-assistant/) (specifically `01-*.md` etc.).
2. **Canonical Workflow Specifications:**
   - The step-by-step instructions and triggers for tasks (setup, scrape, rank, apply, upskill, interview) are defined in the [.claude/](.claude/) directory (specifically under `.claude/skills/` and `.claude/commands/`).
   - Do not duplicate these rules or specifications. Treat `.claude/` files as the single source of truth.
3. **Portal Search Skills:**
   - Job-portal search CLIs live under [.agents/skills/](.agents/skills/) in the portable Agent Skills format (with a `SKILL.md` per portal). Codex and Antigravity discover these automatically; the `/scrape` workflow in [.claude/skills/job-scraper/](.claude/skills/job-scraper/) orchestrates them.

---

## Quick job-search path (start here)

For plain job hunting — no CV tailoring, no LaTeX — everything you need is:

1. **[profile.md](profile.md)** — the candidate profile, in plain Markdown. **Not committed**
   (see `.gitignore`). This file — not a PDF CV — is the input the search runs on: it is short,
   structured, and needs no PDF tooling. If it is missing, see
   [PROMPT-EXTRAER-PERFIL.md](PROMPT-EXTRAER-PERFIL.md) (a copy-paste prompt that turns a CV into
   this format using any chat LLM), or copy [profile.example.md](profile.example.md) and fill it
   in, or paste the CV text into the chat. Reading a PDF is a last resort — it needs `pdftoppm`.
   **Never invent a profile.**
2. **[.claude/skills/job-search/SKILL.md](.claude/skills/job-search/SKILL.md)** — the search
   procedure: which portals to run for the candidate's country, how to filter by level, and the
   output format. Triggers on "dame las ofertas", "busca ofertas", "find jobs".

Portal routing is driven by the **country** in `profile.md`: Computrabajo is Colombia-only,
`linkedin-search` works anywhere, and `freehire-search` covers many countries via `--country`
(ISO alpha-2). The four Danish portals ship with `enabled: false`.

## OpenCode compatibility

This workspace runs under both Claude Code and [OpenCode](https://opencode.ai).

| Feature | Claude Code | OpenCode |
|---|---|---|
| `AGENTS.md` | not read | **read** (wins over `CLAUDE.md`) |
| `CLAUDE.md` | read | only as a fallback when `AGENTS.md` is absent |
| `.claude/skills/` | ✅ | ✅ |
| `.agents/skills/` | read as files by `/scrape` | ✅ discovered as skills |
| `.claude/commands/` (`/apply`, `/setup`, `/rank`, `/interview`) | ✅ | ❌ **not read** — Claude Code only |
| `.claude/agents/` | ✅ | ❌ not read (OpenCode uses `.opencode/agents/`) |

Notes for OpenCode:
- [opencode.json](opencode.json) loads `profile.md` via `instructions` and pre-approves the
  `bun run .agents/skills/*` calls so the scrapers don't prompt on every query.
- OpenCode validates skill frontmatter: `name` **must** match the containing directory name and
  match `^[a-z0-9]+(-[a-z0-9]+)*$`, or the skill is dropped.
- The CV/cover-letter workflows (`/apply`, `/setup`) are Claude Code only. In OpenCode, use the
  `job-search` skill above.
