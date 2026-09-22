# `ports` — interactive port TUI

**Date:** 2026-09-22
**Status:** Approved, pending implementation

## Problem

Dev servers get started across scattered terminal tabs and are easy to lose
track of: which port is which project running on, what's still alive, and how do
I kill the stray one. There's no single place to search a port, see what owns it,
and act on it.

## Goal

A `ports` command that opens a full-screen, searchable TUI of everything
listening locally, enriched with process detail, with hotkeys to kill / open /
copy. Consistent with the existing `dot` and `sim` tools (bash + `fzf` + `gum`).

## Non-goals (YAGNI)

- **Restart / re-launch a process** — we can't reliably reconstruct how a process
  was originally started (env, cwd, shell), so this would be flaky. Excluded.
- **Log tailing** — out of scope; use the owning terminal.
- **Remote / non-TCP / UDP ports** — TCP listeners only.

## Stack & placement

- `bin/ports` — bash script, executable, picked up by the existing
  `PATH=$PATH:$HOME/dotfiles/bin` entry in `zsh/.zshrc`. No symlink needed.
- Dependencies: `fzf` and `gum` — both already in `Brewfile`. Script prints a
  friendly hint and exits non-zero if either is missing (mirrors `bin/sim`'s
  `gum` guard).
- `lsof -nP -iTCP -sTCP:LISTEN` is the data source (already available on macOS).

## Behavior

### Layout

Full-screen `fzf`: left column is the searchable list of listening ports, right
is a live preview pane driven by fzf's `--preview` running a `ports` subcommand
against the selected row. Typing filters instantly. Default view is dev servers
only; a hotkey toggles to all listeners.

```
  PORTS · dev only            search: 30_
┌──────────────────────┬─────────────────────────────┐
│ 3000  node    41221   │ PORT   3000                 │
│ 5432  postgres 88     │ PROC   node (pid 41221)     │
│ 8080  java    9931    │ CMD    next dev             │
│                       │ CWD    ~/code/app           │
│                       │ UPTIME 2h14m                │
│                       │ URL    http://localhost:3000│
└──────────────────────┴─────────────────────────────┘
 enter open · ^k kill · ^y copy url · ^p copy pid · ^d dev/all · ^r refresh · esc quit
```

### Hotkeys

| Key         | Action                                                            |
|-------------|-------------------------------------------------------------------|
| `enter`     | open `http://localhost:<port>` in the default browser (`open`)    |
| `ctrl-k`    | kill the owning process(es) after a `gum confirm`, then refresh   |
| `ctrl-y`    | copy `http://localhost:<port>` to clipboard (`pbcopy`)            |
| `ctrl-p`    | copy the PID to clipboard                                         |
| `ctrl-d`    | toggle dev-only ⇄ all listeners (fzf `reload`)                    |
| `ctrl-r`    | re-scan / refresh (fzf `reload`)                                  |
| `esc` / `q` | quit                                                             |

Kill and refresh use fzf's `reload(...)` binding so the list stays live without
leaving the TUI.

### Dev filter

A process-name regex marks "dev" processes:
`node|python|ruby|deno|bun|next|vite|rails|puma|uvicorn|gunicorn|java|php|dotnet|cargo|air|ts-node|nodemon|webpack|esbuild`.
Default view greps to these; `ctrl-d` toggles the filter off.

## Architecture (functions)

The script is structured so pure helpers can be `source`d without launching the
TUI — same pattern as `bin/dot` (interactive entry guarded; internal work exposed
via `ports <subcommand>` dispatch that fzf's preview/bindings call back into).

- `scan_ports [--all]` → emit one row per TCP listener: `port  proc  pid`.
  When `--all` is absent, filter rows through the dev regex.
- `describe_port <port>` → the preview text (port, proc, pid, full command via
  `ps -o command=`, cwd via `lsof -a -p <pid> -d cwd`, uptime via `ps -o etime=`,
  localhost URL).
- `kill_port <port>` → `lsof -ti tcp:<port> | xargs kill -9`; used by `ctrl-k`
  and by the non-interactive `killport` alias.
- `main` → assembles the `fzf` invocation with `--preview`, `--bind`s, header,
  and layout. Runs only when the script is executed directly, not when sourced.

Subcommand dispatch (so fzf bindings/preview can re-enter the script):
`ports __describe <port>`, `ports __scan [--all]`, `ports __kill <port>`.

## Shell integration

- `zsh/ports.zsh` shrinks to just the non-interactive convenience:
  `killport <port>` (delegates to `bin/ports __kill`). The earlier standalone
  `ports()`/filtering function is removed in favor of the TUI.
- Source `zsh/ports.zsh` from `zsh/.zshrc` alongside the other modules.
- Add `ports` and `killport` rows to the `zhelp` menu in `zsh/aliases.zsh` under
  the `-- Shell --` section.

## Testing

Extend `tests/run.sh` (zero-dependency, no `fzf`/`gum` needed) following the
existing `dot TUI helpers` group:

- `bin/ports parses` — `bash -n bin/ports`.
- `bin/ports is executable`.
- `scan_ports` dev-filter: feed a fixture of fake `lsof` lines and assert dev
  rows are kept and noise (e.g. `Spotify`) is dropped; `--all` keeps everything.
  (Achieved by making the row-filtering a pure function over stdin so no real
  `lsof` is required.)
- `killport() defined` — `zsh -fc "source zsh/ports.zsh; typeset -f killport"`.
- `zhelp` still lists the new entries (contains check).

## Rollout

1. Write `bin/ports`, `chmod +x`.
2. Trim `zsh/ports.zsh` to `killport`; source it from `.zshrc`.
3. Add `zhelp` entries.
4. Add tests; run `make test`.
5. `brew bundle` is already satisfied (fzf, gum present) — no Brewfile change,
   but confirm the two deps are listed (they are).
