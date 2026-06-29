# dotfiles

Personal macOS dotfiles — zsh config, git config, shell aliases, AI-powered git
helpers, and a few CLI tools. Everything is symlinked into `$HOME` by
`install.sh`.

## Install

```sh
git clone <repo-url> ~/dotfiles
cd ~/dotfiles
brew bundle              # install the tools below (optional)
./install.sh
source ~/.zshrc
```

`install.sh` symlinks `~/.zshrc` and `~/.gitconfig` into the repo. If a real
file already exists at either path, it's backed up to `*.bak` before linking.

## Layout

```
zsh/
  .zshrc            # entrypoint — sources the modules below, sets PATH, loads plugins
  history.zsh       # persistent, shared, de-duplicated history
  aliases.zsh       # git + shell aliases, dotfiles helper, zhelp menu
  ai.zsh            # AI helpers backed by `claude -p` (incl. gprc)
  prompt.zsh        # vcs_info-based prompt (user@host, cwd, git branch)
  cb.local.zsh      # machine-local, gitignored (not committed)
git/
  .gitconfig        # user, push.autoSetupRemote, core.excludesfile, rebranch alias
  .gitignore_global # OS/editor cruft ignored in every repo
bin/
  sim               # gum TUI for managing iOS simulators / Android emulators
install.sh          # symlink installer
```

## Requirements

`brew bundle` (from the repo root) installs everything in the [`Brewfile`](Brewfile):

- **zsh** + **git** (macOS defaults)
- [**Claude Code**](https://claude.com/claude-code) CLI (`claude`) — for the AI helpers
- [**gh**](https://cli.github.com/) — for `gprc`
- [**gum**](https://github.com/charmbracelet/gum) — for `sim`
- **rbenv**, **nvm** — referenced in `.zshrc`

The Android SDK (`emulator`, `adb`) for `sim` isn't in the Brewfile — install it
via Android Studio. Remove any `.zshrc` lines for tools you don't use.

## Commands

Run `zhelp` for a colorized list of everything. Highlights:

### Git aliases

| Alias | Runs |
|-------|------|
| `gst` | `git status` |
| `gaa` | `git add .` |
| `gcm` | `git commit -m` |
| `gco` / `gcob` | `git checkout` / `git checkout -b` |
| `gl` | `git log --oneline --graph --decorate -20` |
| `gfap` | `git fetch && git pull` |
| `grh` | `git reset --hard` |
| `grb` | `git rebranch` — recreate a branch off an updated base |
| `gblog [n]` | list the last `n` recently checked-out branches |

### AI helpers (`claude -p`)

These gather context in the shell, pipe it into a headless `claude -p` call, and
use the output — no REPL, no slash commands.

| Command | What it does |
|---------|--------------|
| `gcai` | Generate a Conventional Commits message from the staged diff, then `[y]` commit / `[e]` edit / `[N]` abort. Infers the ticket scope from the branch name. |
| `gprc [base]` | Push and open (or edit) a PR — default base `beta`. Optionally has Claude draft the body from the PR template; `-a`/`--ai` skips the prompt. |
| `greview [base]` | Review the current branch's diff vs `base` (default `beta`) for likely bugs. Read-only. |
| `ask "question"` | One-off question to Claude. Also works as a pipe target: `cmd 2>&1 \| ask "what's wrong"`. |
| `explain` | Explain piped command output or errors: `cmd 2>&1 \| explain`. |

### Shell

| Command | What it does |
|---------|--------------|
| `dotfiles pull` | Pull the latest dotfiles and reload `~/.zshrc` |
| `zedit` | Edit `aliases.zsh` |
| `zrestart` | `source ~/.zshrc` |
| `zhelp` | Show the full command menu |

### `sim`

A [gum](https://github.com/charmbracelet/gum)-based TUI for managing
simulators. List / start / kill iOS simulators (via `simctl`) and Android
emulators (via `emulator` + `adb`). Just run `sim`.

## Local overrides

Anything machine-specific stays out of git:

- `zsh/*.local.zsh` — sourced automatically by `.zshrc`
- `~/.zshrc.local` — sourced if present

Both patterns are covered by `.gitignore` (`*.local`, `*.local.zsh`), so secrets
and per-machine tweaks never get committed.

## License

[MIT](LICENSE) — use it for whatever.
