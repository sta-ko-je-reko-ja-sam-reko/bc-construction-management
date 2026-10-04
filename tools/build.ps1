<#
.SYNOPSIS
    Compiles the app and test projects with the AL compiler and all four Microsoft code analyzers.

.DESCRIPTION
    Mirrors what VS Code does on build, without VS Code:
      1. Refreshes .alpackages from the local BC artifact cache and removes every non-Microsoft package, so a
         previous build of this app can never shadow the source. Microsoft symbols that VS Code holds open are
         left in place when they already match the artifact.
      2. Compiles app/ with CodeCop, UICop, AppSourceCop and PerTenantExtensionCop and app/ruleset.json.
      3. Copies the freshly built app package into test/.alpackages and compiles test/ the same way, with the same
         ruleset (test/ruleset.json includes app/ruleset.json) and the same AppSourceCop affix list.
    Exits non-zero when the compiler reports any error.

.PARAMETER ArtifactPath
    BC sandbox artifact folder that holds the matching platform and W1 application (including the test toolkit).

.PARAMETER AlExtensionPath
    Folder of the installed AL Language extension (its bin folder holds alc.dll and the analyzers).

.PARAMETER DotNetPath
    dotnet.exe of a .NET 10 runtime; the AL 18 compiler needs it.

.PARAMETER Project
    app, test, or all.
#>
[CmdletBinding()]
param(
    [string] $ArtifactPath = 'c:\bcartifacts.cache\sandbox\29.0.54011.55616',
    [string] $AlExtensionPath = (Get-ChildItem "$env:USERPROFILE\.vscode\extensions" -Directory -Filter 'ms-dynamics-smb.al-*' | Sort-Object Name -Descending | Select-Object -First 1).FullName,
    [string] $DotNetPath = (Get-ChildItem "$env:APPDATA\Code\User\globalStorage\ms-dotnettools.vscode-dotnet-runtime\.dotnet" -Directory -Filter '10.*' -ErrorAction SilentlyContinue |
        Where-Object { Test-Path (Join-Path $_.FullName 'dotnet.exe') } |
        Sort-Object { [version](($_.Name -split '~')[0]) } -Descending |
        Select-Object -First 1 | ForEach-Object { Join-Path $_.FullName 'dotnet.exe' }),
    [ValidateSet('app', 'test', 'all')]
    [string] $Project = 'all'
)

$ErrorActionPreference = 'Stop'
$repo = Split-Path $PSScriptRoot -Parent
$bin = Join-Path $AlExtensionPath 'bin'
$alc = Join-Path $bin 'alc.dll'
$analyzers = 'CodeCop', 'UICop', 'AppSourceCop', 'PerTenantExtensionCop' |
    ForEach-Object { "/analyzer:$(Join-Path $bin "Microsoft.Dynamics.Nav.$_.dll")" }

if (-not $DotNetPath -or -not (Test-Path $DotNetPath)) { throw "No .NET 10 runtime found. Pass -DotNetPath." }
if (-not (Test-Path $alc)) { throw "alc.dll not found under $bin. Pass -AlExtensionPath." }

function Update-Symbols([string] $projectDir) {
    $cache = Join-Path $projectDir '.alpackages'
    New-Item -ItemType Directory -Force $cache | Out-Null
    Get-ChildItem $cache -Filter '*.app' | Where-Object { $_.Name -notlike 'Microsoft_*' -and $_.Name -ne 'System.app' } | Remove-Item -Force
    $major = ((Split-Path $ArtifactPath -Leaf) -split '\.')[0]
    $sources = @(Get-Item (Join-Path $ArtifactPath "platform\ModernDev\PFiles\Microsoft Dynamics NAV\${major}0\AL Development Environment\System.app")) +
        @(Get-ChildItem (Join-Path $ArtifactPath 'w1\Extensions') -Filter '*.app')
    foreach ($source in $sources) {
        $target = Join-Path $cache $source.Name
        if ((Test-Path $target) -and ((Get-Item $target).Length -eq $source.Length)) { continue }
        Copy-Item $source.FullName $target -Force
    }
}

function Invoke-Compile([string] $projectDir) {
    $manifest = Get-Content (Join-Path $projectDir 'app.json') -Raw | ConvertFrom-Json
    $out = Join-Path $projectDir ("{0}_{1}_{2}.app" -f $manifest.publisher, $manifest.name, $manifest.version)
    Write-Host "Compiling $($manifest.name) $($manifest.version)" -ForegroundColor Cyan
    $compilerArgs = @(
        $alc,
        "/project:$projectDir",
        "/packagecachepath:$(Join-Path $projectDir '.alpackages')",
        "/out:$out",
        "/ruleset:$(Join-Path $projectDir 'ruleset.json')"
    ) + $analyzers
    & $DotNetPath @compilerArgs | Out-Host
    if ($LASTEXITCODE -ne 0) { throw "Compilation of $($manifest.name) failed." }
    return $out
}

if ($Project -in 'app', 'all') {
    Update-Symbols (Join-Path $repo 'app')
    $appPackage = Invoke-Compile (Join-Path $repo 'app')
}

if ($Project -in 'test', 'all') {
    $testDir = Join-Path $repo 'test'
    Update-Symbols $testDir
    if (-not $appPackage) {
        $appPackage = Get-ChildItem (Join-Path $repo 'app') -Filter '*.app' | Sort-Object LastWriteTime -Descending | Select-Object -First 1 -ExpandProperty FullName
    }
    if (-not $appPackage) { throw 'No app package found. Build the app first (-Project app).' }
    Copy-Item $appPackage (Join-Path $testDir '.alpackages')
    Invoke-Compile $testDir | Out-Null
}
