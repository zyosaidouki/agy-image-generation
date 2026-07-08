[CmdletBinding()]
param(
    [switch]$Check,
    [switch]$Force,
    [string]$Dest
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$SkillName = "agy-image-generation"
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path

if ([string]::IsNullOrWhiteSpace($Dest)) {
    if (-not [string]::IsNullOrWhiteSpace($env:CODEX_HOME)) {
        $DestRoot = Join-Path $env:CODEX_HOME "skills"
    } else {
        $DestRoot = Join-Path $HOME ".codex\skills"
    }
} else {
    $DestRoot = $Dest
}

$DestDir = Join-Path $DestRoot $SkillName

function Require-File {
    param([string]$Path)

    if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) {
        throw "Required file is missing: $Path"
    }
}

Require-File (Join-Path $ScriptDir "SKILL.md")
Require-File (Join-Path $ScriptDir "README.md")
Require-File (Join-Path $ScriptDir "agents\openai.yaml")
Require-File (Join-Path $ScriptDir "references\agy-cli-discovery.md")

Write-Host "Skill: $SkillName"
Write-Host "Source: $ScriptDir"
Write-Host "Target: $DestDir"

$AgyCommand = Get-Command agy -ErrorAction SilentlyContinue
if ($null -ne $AgyCommand) {
    Write-Host "agy: found ($($AgyCommand.Source))"
} else {
    Write-Host "agy: not found in PATH"
    Write-Host "note: install agy CLI before using this skill to generate images."
}

if ($Check) {
    exit 0
}

if ((Test-Path -LiteralPath $DestDir) -and -not $Force) {
    throw "Target already exists: $DestDir. Run with -Force to overwrite the skill files."
}

New-Item -ItemType Directory -Force -Path (Join-Path $DestDir "agents") | Out-Null
New-Item -ItemType Directory -Force -Path (Join-Path $DestDir "references") | Out-Null

Copy-Item -LiteralPath (Join-Path $ScriptDir "SKILL.md") -Destination (Join-Path $DestDir "SKILL.md") -Force
Copy-Item -LiteralPath (Join-Path $ScriptDir "README.md") -Destination (Join-Path $DestDir "README.md") -Force
Copy-Item -LiteralPath (Join-Path $ScriptDir "agents\openai.yaml") -Destination (Join-Path $DestDir "agents\openai.yaml") -Force
Copy-Item -LiteralPath (Join-Path $ScriptDir "references\agy-cli-discovery.md") -Destination (Join-Path $DestDir "references\agy-cli-discovery.md") -Force

Write-Host "Installed $SkillName to $DestDir"
Write-Host "Try: Use `$$SkillName to generate an image with agy CLI."
