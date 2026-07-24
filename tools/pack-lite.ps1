<#
.SYNOPSIS
  Builds the slim "buscador de empleo" ZIP for non-technical users.

.DESCRIPTION
  Unlike tools/pack-share.ps1 (which copies everything and then deletes the personal files),
  this script works from an ALLOWLIST: only the paths named below make it into the package.
  Nothing personal can leak, because profile.md and documents/ are simply never copied.

  It also derives PROMPT.txt from the fenced block inside PROMPT-EXTRAER-PERFIL.md, so the
  plain-text prompt can never drift out of sync with the documented one.

  Files under tools/lite/ are the package's own README / AGENTS / CLAUDE / NOTICE and are
  copied to its root, replacing the full repo's versions.

.EXAMPLE
  powershell -ExecutionPolicy Bypass -File tools\pack-lite.ps1
  powershell -ExecutionPolicy Bypass -File tools\pack-lite.ps1 -OutFile C:\Users\me\Desktop\buscador.zip
#>
[CmdletBinding()]
param(
  [string]$OutFile
)

$ErrorActionPreference = 'Stop'

$repo    = Split-Path -Parent $PSScriptRoot
$overlay = Join-Path $PSScriptRoot 'lite'
$pkgName = 'buscador-empleo'
if (-not $OutFile) { $OutFile = Join-Path (Split-Path -Parent $repo) "$pkgName-lite.zip" }

$stage = Join-Path ([IO.Path]::GetTempPath()) "pack-lite-$([Guid]::NewGuid().ToString('N').Substring(0,8))"
$dest  = Join-Path $stage $pkgName

Write-Host "Repo   : $repo"
Write-Host "Salida : $OutFile"
Write-Host ""

New-Item -ItemType Directory -Path $dest -Force | Out-Null

# ---------------------------------------------------------------- allowlist --
# Archivos sueltos que se copian tal cual.
$archivos = @(
  'LICENSE'                    # MIT de upstream: obligatorio conservarlo
  'profile.example.md'
  'PROMPT-EXTRAER-PERFIL.md'
  'opencode.json'
  '.claude/skills/job-search/SKILL.md'
)

# Carpetas completas, menos lo que sobra dentro de ellas.
$carpetas = @(
  '.agents/skills/linkedin-search'
  '.agents/skills/computrabajo-search'
  '.agents/skills/freehire-search'
)
$subcarpetasExcluidas = @('node_modules', 'tests')

foreach ($rel in $archivos) {
  $src = Join-Path $repo ($rel -replace '/', '\')
  if (-not (Test-Path $src)) { throw "Falta un archivo requerido: $rel" }
  $dst = Join-Path $dest ($rel -replace '/', '\')
  New-Item -ItemType Directory -Path (Split-Path $dst) -Force | Out-Null
  Copy-Item $src $dst -Force
}

foreach ($rel in $carpetas) {
  $src = Join-Path $repo ($rel -replace '/', '\')
  if (-not (Test-Path $src)) { throw "Falta una carpeta requerida: $rel" }
  $dst = Join-Path $dest ($rel -replace '/', '\')
  New-Item -ItemType Directory -Path $dst -Force | Out-Null
  Get-ChildItem $src -Recurse -File | ForEach-Object {
    $sub = $_.FullName.Substring($src.Length).TrimStart('\')
    $partes = $sub -split '\\'
    if ($partes | Where-Object { $subcarpetasExcluidas -contains $_ }) { return }
    $target = Join-Path $dst $sub
    New-Item -ItemType Directory -Path (Split-Path $target) -Force | Out-Null
    Copy-Item $_.FullName $target -Force
  }
}

# ------------------------------------------------------------------ overlay --
Get-ChildItem $overlay -File -Force | ForEach-Object {
  Copy-Item $_.FullName (Join-Path $dest $_.Name) -Force
}

# --------------------------------------------------- PROMPT.txt (derivado) --
# Extrae el bloque ```text ... ``` de PROMPT-EXTRAER-PERFIL.md. Asi la version
# plana y la documentada no pueden desincronizarse.
$md = Get-Content (Join-Path $repo 'PROMPT-EXTRAER-PERFIL.md') -Raw -Encoding UTF8
$m  = [regex]::Match($md, '(?s)`{3,4}text\r?\n(.*?)\r?\n`{3,4}')
if (-not $m.Success) { throw "No encontre el bloque de prompt en PROMPT-EXTRAER-PERFIL.md" }

$prompt = $m.Groups[1].Value -replace "`r?`n", "`r`n"   # CRLF para el Bloc de notas
$encBom = New-Object System.Text.UTF8Encoding $true      # BOM para que se vean los acentos
[IO.File]::WriteAllText((Join-Path $dest 'PROMPT.txt'), $prompt, $encBom)

# --------------------------------------------------------------------- zip --
if (Test-Path -LiteralPath $OutFile) { Remove-Item -LiteralPath $OutFile -Force }
Compress-Archive -Path $dest -DestinationPath $OutFile -CompressionLevel Optimal

# ------------------------------------------------------------------ reporte --
$incluidos = Get-ChildItem $dest -Recurse -File -Force
$sizeKb = '{0:N0}' -f ((Get-Item $OutFile).Length / 1KB)

Write-Host "Contenido del paquete ($($incluidos.Count) archivos):" -ForegroundColor Cyan
$incluidos |
  ForEach-Object { $_.FullName.Substring($dest.Length + 1) } |
  Sort-Object |
  ForEach-Object { Write-Host "  $_" }

# Red de seguridad: si algo personal se colo, avisa fuerte y borra el ZIP.
$sospechosos = $incluidos | Where-Object { $_.Name -eq 'profile.md' -or $_.Extension -eq '.pdf' }
Write-Host ""
if ($sospechosos) {
  Remove-Item -LiteralPath $OutFile -Force
  Write-Host "ABORTADO: se colaron archivos personales, ZIP eliminado:" -ForegroundColor Red
  $sospechosos | ForEach-Object { Write-Host "  $($_.FullName.Substring($dest.Length + 1))" }
  Remove-Item $stage -Recurse -Force
  exit 1
}

Write-Host "Sin datos personales: no hay profile.md ni PDFs." -ForegroundColor Green
Write-Host "ZIP listo : $OutFile" -ForegroundColor Green
Write-Host "Tamano    : $sizeKb KB"
Write-Host ""
Write-Host "Esto es lo que le pasas a tus companeros. Cada uno crea su propio profile.md." -ForegroundColor Cyan

Remove-Item $stage -Recurse -Force
