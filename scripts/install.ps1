# Link rizo into Typora's themes folder (Windows) for development.
# Edits in this repo show up in Typora after Themes > rizo is re-selected or Typora restarts.
# Usage (PowerShell):  scripts\install.ps1 [-Uninstall]
# Set $env:TYPORA_THEMES to override the themes folder.
#
# File symlinks need Developer Mode (Settings > System > For developers) or an
# admin PowerShell. The rizo\ folder uses a directory junction, which needs neither.
param([switch]$Uninstall)
$ErrorActionPreference = 'Stop'

$Repo = Split-Path -Parent $PSScriptRoot
$Themes = if ($env:TYPORA_THEMES) { $env:TYPORA_THEMES } else { Join-Path $env:APPDATA 'Typora\themes' }

if (-not (Test-Path -LiteralPath $Themes -PathType Container)) {
  Write-Error "Typora themes folder not found: $Themes`nOpen Typora > Settings > Appearance > Open Theme Folder once, or set `$env:TYPORA_THEMES."
}

function Test-Link($Path) {
  $item = Get-Item -LiteralPath $Path -Force -ErrorAction SilentlyContinue
  return $item -and ($item.Attributes -band [IO.FileAttributes]::ReparsePoint)
}

foreach ($name in 'rizo.css', 'rizo-dark.css', 'rizo') {
  $target = Join-Path $Themes $name
  $source = Join-Path $Repo $name

  if ($Uninstall) {
    if (Test-Link $target) {
      # Remove only the link, never the repo files it points to.
      (Get-Item -LiteralPath $target -Force).Delete()
      Write-Host "removed $target"
    }
    continue
  }

  if (Test-Path -LiteralPath $target) {
    if (-not (Test-Link $target)) { Write-Error "refusing to replace a real file or folder: $target (move it first)" }
    (Get-Item -LiteralPath $target -Force).Delete()
  }

  if ($name -eq 'rizo') {
    New-Item -ItemType Junction -Path $target -Target $source | Out-Null
  } else {
    try {
      New-Item -ItemType SymbolicLink -Path $target -Target $source | Out-Null
    } catch {
      Write-Error "Could not create a symlink for $name. Enable Developer Mode (Settings > System > For developers) or run PowerShell as administrator, then try again."
    }
  }
  Write-Host "linked $target -> $source"
}
