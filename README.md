# Scan-Repo

A bash script that scans a repository for prompt injection risks and malicious code patterns that could compromise AI coding agents (Claude, Cursor, Gemini) and editors like VS Code.

## What it checks

| # | Check | What it catches |
|---|-------|-----------------|
| 1 | AI agent config directories | `.claude`, `.cursor`, `.gemini` directories — their presence means an AI agent reads and acts on files here |
| 2 | VS Code auto-run tasks | Tasks with `"runOn": "folderOpen"` execute automatically when someone opens the project |
| 3 | Suspicious shell scripts | `eval`, `bash -c`, `curl`/`wget` piped to a shell, and `base64 --decode`/`-d` in `.sh`, `.bash`, and `.zsh` files |
| 4 | Invisible Unicode characters | U+200B (zero-width space), U+200C (zero-width non-joiner), U+200D (zero-width joiner), U+202E (right-to-left override) — used to hide malicious code in plain sight |
| 5 | Large single-line files | Files over 50 KB with content on a single line — a common obfuscation technique for minified payloads |
| 6 | Suspicious JSON/YAML patterns | `postinstall`/`preinstall` npm lifecycle hooks (supply chain risk), `runOn` (auto-execution), `eval` in config files |

## Usage

```bash
# Scan the current directory
bash scan-repo.sh

# Scan a specific path
bash scan-repo.sh /path/to/repo

# Make it executable and run directly
chmod +x scan-repo.sh
./scan-repo.sh /path/to/repo
```

The script prints findings to stdout as it runs each check. Lines with no output under a check header mean nothing suspicious was found for that check.

## Testing with the included test files

The `Test-Files/` directory contains realistic sample files designed to exercise every check — including false-positive scenarios you would encounter in real projects.

```bash
bash scan-repo.sh Test-Files
```

### Expected output and what each file tests

#### Check 1 — AI agent config directories
| File | Purpose |
|------|---------|
| `Test-Files/.claude/settings.json` | Realistic Claude Code config. Should be detected as a `.claude` directory. |
| `Test-Files/.cursor/mcp.json` | Cursor MCP server config granting filesystem access. Should be detected as a `.cursor` directory. |

#### Check 2 — VS Code auto-run tasks
| File | Purpose |
|------|---------|
| `Test-Files/.vscode/tasks.json` | Contains a task with `"runOn": "folderOpen"` that starts a dev server automatically. Should be detected. |
| `Test-Files/.vscode/settings.json` | Normal editor settings with no auto-run. Should produce no output — false positive control. |

#### Check 3 — Suspicious shell scripts
| File | Purpose |
|------|---------|
| `Test-Files/scripts/bootstrap.sh` | Decodes a base64-encoded payload and pipes it to `bash -c` — a classic obfuscation technique. Should be detected. |
| `Test-Files/scripts/update-deps.sh` | Fetches a remote script into a variable with `curl`, then runs it via `eval` — two lines apart, both flagged. Should be detected. |
| `Test-Files/scripts/deploy.sh` | Legitimate deployment script that uses `curl` to download a release artifact to a file. Should **not** be detected — false positive control. |

#### Check 4 — Invisible Unicode characters
| File | Purpose |
|------|---------|
| `Test-Files/src/auth.js` | Contains U+200B zero-width spaces embedded inside JavaScript identifier names (`validateToken`, `hash`). The code appears normal in most editors but the hidden characters can confuse parsers or hide alternate logic. Should be detected. |
| `Test-Files/src/config.py` | Contains a U+202E right-to-left override character in a comment, reversing the visual rendering of the text to disguise what the line actually says. Should be detected. |

#### Check 5 — Large single-line files
| File | Purpose |
|------|---------|
| `Test-Files/dist/bundle.min.js` | Simulated minified JavaScript bundle — ~81 KB on a single line, the format used to hide obfuscated payloads. Should be detected. |
| `Test-Files/assets/data.json` | Large JSON file (~130 KB) split across many lines. Should **not** be detected — false positive control to confirm the check is line-length-aware, not just file-size-aware. |

#### Check 6 — Suspicious JSON/YAML patterns
| File | Purpose |
|------|---------|
| `Test-Files/assets/suspicious-package.json` | npm package with `postinstall` and `preinstall` hooks that download and execute remote scripts — a supply chain attack pattern. Should be detected. |
| `Test-Files/package.json` | Normal npm project with a standard `"scripts"` block (`dev`, `build`, `test`). Should **not** be detected — false positive control showing the check does not flag every package.json. |
| `Test-Files/.github/workflows/deploy.yml` | Standard GitHub Actions CI workflow using AWS CLI. Should **not** be detected — false positive control. |
