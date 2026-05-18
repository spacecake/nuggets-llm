# nuggets-llm

A collection of practical utility scripts for working with LLM tools, agents, and workflows.

No theory. No fluff. Just scripts that solve real setup and workflow problems when working with AI tooling day to day.

## What lives here

Scripts are organized by category. Each tool has its own folder with a dedicated README covering purpose, prerequisites, and usage.

| Category | Description |
|---|---|
| `setup/` | Installation and environment setup scripts |
| `workflows/` | Scripts supporting prompt pipelines and agent workflows |
| `utils/` | Standalone utility scripts for LLM-adjacent tasks |

## Philosophy

- Every script must be idempotent: safe to run more than once
- Minimal dependencies: use what the OS or the target toolchain already provides
- Each tool is self-contained with its own documentation
- OS and tool coverage noted explicitly per script; no silent assumptions

## Current scripts

| Script | OS | Description |
|---|---|---|
| `setup/setup-ai-cli-tools.ps1` | Windows | Installs Claude Code, Codex CLI, and a curated set of agent skills with all prerequisites |

## Contributing

Scripts for any OS and any LLM toolchain are welcome. Requirements:

- Idempotent
- Documented with a README following the format in existing tools
- Tested before submission

## License

MIT
