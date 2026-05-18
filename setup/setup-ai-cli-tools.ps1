# =============================================================================
# setup-ai-cli-tools.ps1
# Prerequisites for Claude Code and Codex CLI on Windows
# Run as Administrator in PowerShell
# =============================================================================

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Write-Step { param([string]$msg) Write-Host "`n==> $msg" -ForegroundColor Cyan }
function Write-OK   { param([string]$msg) Write-Host "    OK: $msg" -ForegroundColor Green }
function Write-Warn { param([string]$msg) Write-Host "    WARN: $msg" -ForegroundColor Yellow }

function Reload-Path {
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" +
                [System.Environment]::GetEnvironmentVariable("Path","User")
}

# -----------------------------------------------------------------------------
# 0. Execution policy (must be first - unblocks npm.ps1 and other scripts)
# -----------------------------------------------------------------------------
Write-Step "Execution Policy"
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser -Force
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope LocalMachine -Force
Write-OK "RemoteSigned set for CurrentUser and LocalMachine"

# -----------------------------------------------------------------------------
# 1. Chocolatey
# -----------------------------------------------------------------------------
Write-Step "Chocolatey"
if (-not (Get-Command choco -ErrorAction SilentlyContinue)) {
    Write-Host "    Installing Chocolatey..."
    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
    Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
    Reload-Path
    Write-OK "Chocolatey installed"
} else {
    Write-OK "Already present: $(choco --version)"
}

# -----------------------------------------------------------------------------
# 2. Git (Claude Code uses Git Bash internally on Windows)
# -----------------------------------------------------------------------------
Write-Step "Git"
if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    choco install git -y --params "/GitAndUnixToolsOnPath /WindowsTerminal"
    Reload-Path
    Write-OK "Git installed"
} else {
    Write-OK "Already present: $(git --version)"
}

# -----------------------------------------------------------------------------
# 3. Node.js 22 LTS (satisfies Claude Code >= 18 AND Codex CLI >= 22)
# -----------------------------------------------------------------------------
Write-Step "Node.js 22 LTS"
$nodeOK = $false
if (Get-Command node -ErrorAction SilentlyContinue) {
    $nodeVer = [int](node --version).TrimStart('v').Split('.')[0]
    if ($nodeVer -ge 22) {
        Write-OK "Already present: v$nodeVer"
        $nodeOK = $true
    } else {
        Write-Warn "Found v$nodeVer - upgrading to 22 LTS..."
    }
}
if (-not $nodeOK) {
    choco install nodejs-lts -y
    Reload-Path
    Write-OK "Node.js installed: $(node --version)"
}

# -----------------------------------------------------------------------------
# 4. ripgrep (improves Claude Code search performance)
# -----------------------------------------------------------------------------
Write-Step "ripgrep"
if (-not (Get-Command rg -ErrorAction SilentlyContinue)) {
    choco install ripgrep -y
    Reload-Path
    Write-OK "ripgrep installed"
} else {
    Write-OK "Already present"
}

# -----------------------------------------------------------------------------
# 5. Claude Code (Anthropic native installer)
# -----------------------------------------------------------------------------
Write-Step "Claude Code"
$claudeLocalBin = "$env:USERPROFILE\.local\bin"
# Ensure the local bin is in user PATH before installing
$userPath = [System.Environment]::GetEnvironmentVariable("Path","User")
if ($userPath -notlike "*$claudeLocalBin*") {
    [System.Environment]::SetEnvironmentVariable(
        "Path",
        $userPath + ";$claudeLocalBin",
        "User"
    )
    Reload-Path
    Write-OK "Added $claudeLocalBin to user PATH"
}
if (-not (Get-Command claude -ErrorAction SilentlyContinue)) {
    Write-Host "    Running Anthropic native installer..."
    Invoke-RestMethod https://claude.ai/install.ps1 | Invoke-Expression
    Reload-Path
    Write-OK "Claude Code installed"
} else {
    Write-OK "Already present: $(claude --version)"
    Write-Host "    To update: claude update" -ForegroundColor DarkGray
}

# -----------------------------------------------------------------------------
# 6. Codex CLI
# -----------------------------------------------------------------------------
Write-Step "Codex CLI"
if (-not (Get-Command codex -ErrorAction SilentlyContinue)) {
    npm install -g @openai/codex
    Reload-Path
    Write-OK "Codex CLI installed"
} else {
    Write-OK "Already present: $(codex --version)"
    Write-Host "    To update: npm install -g @openai/codex@latest" -ForegroundColor DarkGray
}

# -----------------------------------------------------------------------------
# 7. agent-skills-cli
# -----------------------------------------------------------------------------
Write-Step "agent-skills-cli"
$skillsCheck = npm list -g agent-skills-cli 2>$null | Select-String "agent-skills-cli"
if (-not $skillsCheck) {
    npm install -g agent-skills-cli
    Write-OK "agent-skills-cli installed"
} else {
    Write-OK "Already present"
}

# -----------------------------------------------------------------------------
# 8. Example Skills Installs
# -----------------------------------------------------------------------------
Write-Step "Find Skills (vercel-labs)"
npx skills add https://github.com/vercel-labs/skills --skill find-skills
Write-OK "ResumeSkills installed/refreshed"
Write-Step "ResumeSkills (Paramchoudhary)"
npx skills add Paramchoudhary/ResumeSkills -g -y
Write-OK "ResumeSkills installed/refreshed"
Write-Step "Docker-compose-orchestration (manutej)"
npx skills add https://github.com/manutej/luxor-claude-marketplace --skill docker-compose-orchestration
Write-OK "Docker-compose-orch installed/refreshed"

# -----------------------------------------------------------------------------
# Summary
# -----------------------------------------------------------------------------
Write-Host "`n============================================================" -ForegroundColor White
Write-Host "  Verification" -ForegroundColor White
Write-Host "============================================================" -ForegroundColor White
Write-Host "  node   : $(node --version 2>$null)"
Write-Host "  npm    : $(npm --version 2>$null)"
Write-Host "  git    : $((git --version 2>$null) -replace 'git version ','')"
Write-Host "  claude : $(claude --version 2>$null)"
Write-Host "  codex  : $(codex --version 2>$null)"
Write-Host ""
Write-Host "  Skills (Claude Code) : $env:USERPROFILE\.claude\skills\" -ForegroundColor DarkGray
Write-Host "  Skills (Codex)       : $env:USERPROFILE\.codex\skills\" -ForegroundColor DarkGray
Write-Host ""
Write-Host "  Next steps:" -ForegroundColor Yellow
Write-Host "    Restart your terminal, then:"
Write-Host "    1. claude   - authenticate with Anthropic account"
Write-Host "    2. codex    - authenticate with ChatGPT/OpenAI account"
Write-Host "============================================================`n" -ForegroundColor White
