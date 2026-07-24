<#
  Revisa que todo este listo antes de la primera busqueda.
  Uso:  powershell -ExecutionPolicy Bypass -File revisar-perfil.ps1
#>

$ErrorActionPreference = 'Continue'
$here = if ($PSScriptRoot) { $PSScriptRoot } else { (Get-Location).Path }
$problemas = New-Object System.Collections.Generic.List[string]

function Ok([string]$m)   { Write-Host "  [OK]    $m" -ForegroundColor Green }
function Mal([string]$m)  { Write-Host "  [FALTA] $m" -ForegroundColor Red; $script:problemas.Add($m) }
function Aviso([string]$m){ Write-Host "  [OJO]   $m" -ForegroundColor Yellow }

Write-Host ""
Write-Host "Revisando tu instalacion..." -ForegroundColor Cyan
Write-Host ""

# --- 1. Bun -----------------------------------------------------------------
Write-Host "1. Bun (motor de los buscadores)"
$bun = Get-Command bun -ErrorAction SilentlyContinue
if (-not $bun) {
  $alt = Join-Path $env:USERPROFILE ".bun\bin\bun.exe"
  if (Test-Path $alt) { $bun = Get-Item $alt }
}
if ($bun) {
  $v = (& $bun.Source --version 2>&1 | Select-Object -First 1)
  Ok "instalado (version $v)"
} else {
  Mal "Bun no esta instalado. Mira el paso 1 del README.md"
}

# --- 2. profile.md ----------------------------------------------------------
Write-Host ""
Write-Host "2. Tu perfil (profile.md)"
$perfil = Join-Path $here "profile.md"
if (-not (Test-Path $perfil)) {
  Mal "no existe profile.md. Sin el, el agente no puede buscar. Mira el paso 3 del README.md"
} else {
  Ok "el archivo existe"
  $texto = Get-Content $perfil -Raw -Encoding UTF8

  # Los acentos van como '.' para que este script sea ASCII puro y no dependa
  # de como PowerShell interprete la codificacion del archivo .ps1
  $campos = @(
    @{ Etiqueta = 'Pais de busqueda';    Patron = 'Pa.s de b.squeda:\s*(.+)' },
    @{ Etiqueta = 'Codigo ISO del pais'; Patron = 'C.digo ISO del pa.s:\s*(.+)' },
    @{ Etiqueta = 'Nivel';               Patron = '\*\*Nivel:\*\*\s*(.+)' },
    @{ Etiqueta = 'Categorias de busqueda'; Patron = '##\s*Categor.as de b.squeda\s*\r?\n([\s\S]{0,400})' }
  )

  foreach ($c in $campos) {
    $m = [regex]::Match($texto, $c.Patron)
    if (-not $m.Success) {
      Mal ("falta la seccion '{0}'" -f $c.Etiqueta)
      continue
    }
    # Quita los ** del markdown para que el mensaje se lea limpio
    $valor = ($m.Groups[1].Value.Trim() -replace '^\*+\s*', '' -replace '\s*\*+$', '').Trim()
    if ($valor -match '\[.+\]') {
      Mal ("'{0}' sigue con el texto de ejemplo sin llenar: {1}" -f $c.Etiqueta, ($valor -split "`n")[0].Trim())
    } elseif ([string]::IsNullOrWhiteSpace($valor) -or $valor -match '^\**\s*$') {
      Mal ("'{0}' esta vacio" -f $c.Etiqueta)
    } else {
      Ok ("{0}: {1}" -f $c.Etiqueta, ($valor -split "`n")[0].Trim())
    }
  }

  # El ISO debe ser dos letras
  $iso = [regex]::Match($texto, 'C.digo ISO del pa.s:\s*\**\s*([A-Za-z]{2})\b')
  if ($iso.Success) {
    Ok ("el codigo ISO '{0}' tiene el formato correcto" -f $iso.Groups[1].Value.ToUpper())
  } else {
    Aviso "el codigo ISO deberia ser exactamente dos letras (CO, CH, ES, MX...)"
  }
}

# --- 3. Buscadores ----------------------------------------------------------
Write-Host ""
Write-Host "3. Buscadores instalados"
foreach ($p in @('linkedin-search','computrabajo-search','freehire-search')) {
  $cli = Join-Path $here ".agents\skills\$p\cli\src\cli.ts"
  if (Test-Path $cli) { Ok $p } else { Mal "falta el buscador $p" }
}

# --- Resumen ----------------------------------------------------------------
Write-Host ""
if ($problemas.Count -eq 0) {
  Write-Host "Todo listo. Abre una terminal en esta carpeta, escribe 'opencode'" -ForegroundColor Green
  Write-Host "y pide: dame las ofertas de las ultimas 24 horas" -ForegroundColor Green
  Write-Host ""
  exit 0
} else {
  Write-Host ("Hay {0} cosa(s) por resolver:" -f $problemas.Count) -ForegroundColor Red
  $problemas | ForEach-Object { Write-Host "  - $_" }
  Write-Host ""
  Write-Host "Si no sabes como arreglarlo, abre 'opencode' en esta carpeta y pegale este mensaje." -ForegroundColor Cyan
  Write-Host ""
  exit 1
}
