<#
.SYNOPSIS
  Builds a shareable ZIP of this workspace with every personal file stripped out.

.DESCRIPTION
  A ZIP ignores .gitignore, so zipping the folder by hand would ship your profile, your CV and
  your application history to whoever you send it to. This script stages a copy, deletes the
  personal files from the staging copy, zips that, and prints what it removed so you can check
  before sending.

.EXAMPLE
  powershell -ExecutionPolicy Bypass -File tools\pack-share.ps1
  powershell -ExecutionPolicy Bypass -File tools\pack-share.ps1 -OutFile C:\Users\me\Desktop\job-agent.zip
#>
[CmdletBinding()]
param(
  [string]$OutFile
)

$ErrorActionPreference = 'Stop'

$repo = Split-Path -Parent $PSScriptRoot
$name = Split-Path -Leaf $repo
if (-not $OutFile) { $OutFile = Join-Path (Split-Path -Parent $repo) "$name-share.zip" }

$stage = Join-Path ([IO.Path]::GetTempPath()) "pack-share-$([Guid]::NewGuid().ToString('N').Substring(0,8))"
$dest  = Join-Path $stage $name

Write-Host "Repo   : $repo"
Write-Host "Staging: $dest"
Write-Host ""

New-Item -ItemType Directory -Path $dest -Force | Out-Null
Copy-Item -Path (Join-Path $repo '*') -Destination $dest -Recurse -Force

# Personal / machine-local paths, relative to the repo root.
# Globs are resolved against the staging copy; missing entries are fine.
$excludePaths = @(
  'profile.md'                      # your candidate profile
  '.git'                            # history can contain personal commits
  '.claude/settings.local.json'     # local permissions with your username in the paths
  'job_scraper/seen_jobs.json'      # which jobs you have already looked at
  'job_search_tracker.csv'          # where you have applied
  'salary_data.json'                # salary benchmarks
  'upskill/*.md'                    # generated learning plans
  'cv/main_*.tex'                   # generated CVs
  'cv/*.txt'
  'cover_letters/cover_*.tex'       # generated cover letters
  'cover_letters/Cover_*.tex'
)

# Kept despite matching a pattern above: the stock examples the templates need.
$keep = @('cv/main_example.tex', 'cover_letters/cover_example.tex')
$keepFull = $keep | ForEach-Object { (Join-Path $dest ($_ -replace '/', '\')) }

$removed = New-Object System.Collections.Generic.List[string]

function Remove-Staged([string]$fullPath) {
  if (-not (Test-Path -LiteralPath $fullPath)) { return }
  if ($keepFull -contains $fullPath) { return }
  Remove-Item -LiteralPath $fullPath -Recurse -Force
  $script:removed.Add($fullPath.Substring($dest.Length + 1))
}

foreach ($pattern in $excludePaths) {
  $full = Join-Path $dest ($pattern -replace '/', '\')
  if ($full -match '[*?]') {
    Get-Item -Path $full -Force -ErrorAction SilentlyContinue | ForEach-Object { Remove-Staged $_.FullName }
  } else {
    Remove-Staged $full
  }
}

# documents/: keep the folder structure and the README, drop every actual document.
Get-ChildItem (Join-Path $dest 'documents') -Recurse -File -Force -ErrorAction SilentlyContinue |
  Where-Object { $_.Name -notin @('.gitkeep', 'README.md') } |
  ForEach-Object { Remove-Staged $_.FullName }

# Belt and braces: no PDFs and no dependency trees anywhere in the payload.
Get-ChildItem $dest -Recurse -File -Force -Filter *.pdf -ErrorAction SilentlyContinue |
  ForEach-Object { Remove-Staged $_.FullName }
Get-ChildItem $dest -Recurse -Directory -Force -ErrorAction SilentlyContinue |
  Where-Object Name -eq 'node_modules' |
  ForEach-Object { Remove-Staged $_.FullName }

if (Test-Path -LiteralPath $OutFile) { Remove-Item -LiteralPath $OutFile -Force }
Compress-Archive -Path $dest -DestinationPath $OutFile -CompressionLevel Optimal

$sizeMb = '{0:N1}' -f ((Get-Item $OutFile).Length / 1MB)
$fileCount = (Get-ChildItem $dest -Recurse -File -Force).Count

Write-Host "Excluido del ZIP ($($removed.Count) rutas):" -ForegroundColor Yellow
if ($removed.Count -eq 0) { Write-Host "  (nada: no habia archivos personales)" }
else { $removed | Sort-Object | ForEach-Object { Write-Host "  - $_" } }

Write-Host ""
Write-Host "ZIP listo : $OutFile" -ForegroundColor Green
Write-Host "Contenido : $fileCount archivos, $sizeMb MB"
Write-Host ""
Write-Host "Revisa la lista de arriba antes de enviarlo." -ForegroundColor Cyan

Remove-Item $stage -Recurse -Force
