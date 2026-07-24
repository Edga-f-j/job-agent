#!/usr/bin/env bash
# Builds a shareable ZIP of this workspace with every personal file stripped out.
#
# A ZIP ignores .gitignore, so zipping the folder by hand would ship your profile, your CV and
# your application history to whoever you send it to. This stages a copy, deletes the personal
# files from the staging copy, zips that, and prints what it removed so you can check first.
#
# Usage:
#   bash tools/pack-share.sh [output.zip]

set -euo pipefail

repo="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
name="$(basename "$repo")"
out="${1:-$(dirname "$repo")/$name-share.zip}"

stage="$(mktemp -d)"
dest="$stage/$name"

echo "Repo   : $repo"
echo "Staging: $dest"
echo

mkdir -p "$dest"
cp -R "$repo/." "$dest/"

removed=()
drop() {
  local rel="$1"
  local full="$dest/$rel"
  [ -e "$full" ] || return 0
  rm -rf "$full"
  removed+=("$rel")
}

# Personal / machine-local paths, relative to the repo root.
drop 'profile.md'                    # your candidate profile
drop '.git'                          # history can contain personal commits
drop '.claude/settings.local.json'   # local permissions with your username in the paths
drop 'job_scraper/seen_jobs.json'    # which jobs you have already looked at
drop 'job_search_tracker.csv'        # where you have applied
drop 'salary_data.json'              # salary benchmarks

# Generated output. The stock *_example files stay: the templates need them.
while IFS= read -r -d '' f; do
  rel="${f#$dest/}"
  case "$rel" in
    cv/main_example.tex|cover_letters/cover_example.tex) continue ;;
  esac
  rm -f "$f"; removed+=("$rel")
done < <(find "$dest" -type f \( \
      -path "$dest/upskill/*.md" -o \
      -path "$dest/cv/main_*.tex" -o -path "$dest/cv/*.txt" -o \
      -path "$dest/cover_letters/cover_*.tex" -o -path "$dest/cover_letters/Cover_*.tex" \
    \) -print0)

# documents/: keep the folder structure and the README, drop every actual document.
while IFS= read -r -d '' f; do
  base="$(basename "$f")"
  [ "$base" = ".gitkeep" ] && continue
  [ "$base" = "README.md" ] && continue
  rel="${f#$dest/}"; rm -f "$f"; removed+=("$rel")
done < <(find "$dest/documents" -type f -print0 2>/dev/null || true)

# Belt and braces: no PDFs and no dependency trees anywhere in the payload.
while IFS= read -r -d '' f; do
  rel="${f#$dest/}"; rm -f "$f"; removed+=("$rel")
done < <(find "$dest" -type f -name '*.pdf' -print0)
while IFS= read -r -d '' d; do
  rel="${d#$dest/}"; rm -rf "$d"; removed+=("$rel")
done < <(find "$dest" -type d -name node_modules -prune -print0)

rm -f "$out"
(cd "$stage" && zip -qr "$out" "$name")

echo "Excluido del ZIP (${#removed[@]} rutas):"
if [ ${#removed[@]} -eq 0 ]; then
  echo "  (nada — no habia archivos personales)"
else
  printf '  - %s\n' "${removed[@]}" | sort
fi

echo
echo "ZIP listo : $out"
echo "Contenido : $(find "$dest" -type f | wc -l | tr -d ' ') archivos, $(du -h "$out" | cut -f1)"
echo
echo "Revisa la lista de arriba antes de enviarlo."

rm -rf "$stage"
