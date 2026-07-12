[CmdletBinding()]
param(
    [switch]$Check,
    [switch]$Force,
    [Alias("Global")]
    [switch]$GlobalInstall,
    [Alias("Local")]
    [switch]$LocalInstall,
    [string]$Dest
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$SkillName = "agy-image-generation"
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path

if (-not [string]::IsNullOrWhiteSpace($env:CODEX_HOME)) {
    $GlobalDestRoot = Join-Path $env:CODEX_HOME "skills"
} else {
    $GlobalDestRoot = Join-Path $HOME ".codex\skills"
}
$LocalDestRoot = Join-Path $ScriptDir ".codex\skills"

if ($GlobalInstall -and $LocalInstall) {
    throw "Choose only one install scope: -Global or -Local."
}
if (-not [string]::IsNullOrWhiteSpace($Dest) -and ($GlobalInstall -or $LocalInstall)) {
    throw "-Dest cannot be combined with -Global or -Local."
}

if (-not [string]::IsNullOrWhiteSpace($Dest)) {
    $Scope = "custom"
    $DestRoot = $Dest
} elseif ($GlobalInstall) {
    $Scope = "global"
    $DestRoot = $GlobalDestRoot
} elseif ($LocalInstall) {
    $Scope = "local"
    $DestRoot = $LocalDestRoot
} else {
    Write-Host "Choose install scope:"
    Write-Host "  1) global: $GlobalDestRoot"
    Write-Host "  2) local:  $LocalDestRoot"
    $Answer = Read-Host "Install globally? [Y/n]"

    switch -Regex ($Answer) {
        "^\s*$" {
            $Scope = "global"
            $DestRoot = $GlobalDestRoot
            break
        }
        "^(y|yes|1)$" {
            $Scope = "global"
            $DestRoot = $GlobalDestRoot
            break
        }
        "^(n|no|2)$" {
            $Scope = "local"
            $DestRoot = $LocalDestRoot
            break
        }
        default {
            throw "Enter y for global or n for local."
        }
    }
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
Write-Host "Scope: $Scope"
Write-Host "Global target root: $GlobalDestRoot"
Write-Host "Local target root: $LocalDestRoot"
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
