# setup-ai-cli-tools

Idempotent PowerShell setup script for installing Claude Code, Codex CLI, and some on Windows, with all required prerequisites.

Safe to run multiple times. Skips anything already installed.

## What it installs

| Tool | Method | Notes |
|---|---|---|
| Chocolatey | Bootstrap script | Package manager for all choco-based installs |
| Git | Chocolatey | Required by Claude Code internally; provides Git Bash shell |
| Node.js 22 LTS | Chocolatey | Satisfies Claude Code (18+) and Codex CLI (22+) |
| ripgrep | Chocolatey | Improves Claude Code file search performance |
| Claude Code | Anthropic native installer | Recommended over npm install |
| Codex CLI | npm | `@openai/codex` |
| agent-skills-cli | npm | Skill manager for Claude Code and Codex |
| find-skills | agent-skills-cli | Skill discovery tool by vercel-labs |
| ResumeSkills | agent-skills-cli | 20 job-search skills by Paramchoudhary |
| docker-compose-orchestration | agent-skills-cli | Docker Compose orchestration skill by manutej (luxor-claude-marketplace) |

## Prerequisites

- Windows 10 or later
- PowerShell running as Administrator
- Internet access

## Usage

**First run only:** set the execution policy manually so the script can load.

```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope LocalMachine -Force
```

Then run the script:

```powershell
.\setup-ai-cli-tools.ps1
```

On all subsequent runs, just execute the script directly. No manual steps needed.

## After installation

Restart your terminal, then authenticate each tool:

```powershell
claude    # browser OAuth with your Anthropic account (Pro or Max required)
codex     # browser OAuth with your ChatGPT/OpenAI account (Plus or higher required)
```

## Skills location

| Tool | Path |
|---|---|
| Claude Code | `%USERPROFILE%\.claude\skills\` |
| Codex | `%USERPROFILE%\.codex\skills\` |

## Notes

- The `npm warn deprecated glob` message during `agent-skills-cli` install is a warning from an internal dependency, not an error. The install succeeds.
- Claude Code is installed via the Anthropic native installer (`https://claude.ai/install.ps1`), which places the binary in `%USERPROFILE%\.local\bin`. The script adds this to the user PATH automatically.
- Node.js is pinned to LTS via Chocolatey. If a version below 22 is found, the script upgrades it.

## License

MIT
