# dotfiles control center (`dot`) — design

Date: 2026-06-29

## Goal

A TUI "control center" for the dotfiles repo that lets you discover what the
repo offers, customize the shell (prompt themes + module toggles), and manage
the repo — all from one gum-based interface, consistent with the existing `sim`
tool.

## Decisions

- **Build:** a gum-based bash script at `bin/dot`, mirroring `bin/sim`. No new
  toolchain; keeps the "clone + source" simplicity. Launchable as `dot` or
  `dotfiles` (bare). `dotfiles pull` and `dotfiles help` (→ `zhelp`) preserved.
- **Sections:** Commands (browse + copy), Customize (themes, AI generation,
  promote, module toggles), Manage (update, status, install, edit), Help.
- **Themes:** ~20 self-contained theme files in `zsh/themes/`, each setting
  `PROMPT` (optionally `RPROMPT`) with built-in zsh + `vcs_info` only — no
  oh-my-zsh dependency, fast, Linux-portable.
- **Theme selection persistence:** one line, `DOTFILES_THEME=<name>`, in the
  gitignored `zsh/settings.local.zsh`. `zsh/theme.zsh` (sourced from `.zshrc`,
  replacing the old `prompt.zsh`) reads it and sources the matching theme. The
  TUI only ever rewrites that gitignored line — it never edits committed files
  to change the prompt.
- **AI theme generation:** Customize → "Generate theme (AI)" pipes a description
  to `claude -p` (same pattern as `gcai`/`gprc`), writes the result to the
  gitignored `zsh/themes/local/`, previews it (rendered via `zsh -f` + `vcs_info`
  in the repo), and offers keep/apply/regenerate/discard.
- **Promotion:** generated themes live in `zsh/themes/local/` (gitignored,
  per-machine). A "Promote local theme" action moves one into the committed
  `zsh/themes/` set. Built-in and local themes resolve through the same lookup.
- **Module toggles:** `DOTFILES_AUTOSUGGEST`, `DOTFILES_HIGHLIGHT`,
  `DOTFILES_HISTORY_SHARE` in `settings.local.zsh`, read by `.zshrc` /
  `history.zsh` (default on).

## Components

| Unit | Responsibility | Depends on |
|------|----------------|------------|
| `bin/dot` | TUI; sourceable (entrypoint guarded) so helpers are testable | gum, claude (AI only), git |
| `zsh/theme.zsh` | resolve + source the active theme; set up `vcs_info`/`precmd` once | `settings.local.zsh` (for `DOTFILES_THEME`) |
| `zsh/themes/*.zsh` | self-contained prompt definitions | zsh prompt escapes, `vcs_info_msg_0_` |
| `zsh/settings.local.zsh` | gitignored active settings (theme + toggles) | written by `dot` |
| `tests/run.sh` | zero-dependency verification of all of the above | bash, zsh, git |

## Testing

`tests/run.sh` (`make test`): script syntax (bash + zsh), every theme parses and
sets a non-empty PROMPT, the loader handles valid and unknown themes,
`settings_get`/`settings_set` round-trip, `list_themes`, `install.sh`
symlinking + backup in a sandbox HOME, and git-config parsing.

## Non-goals

- No oh-my-zsh adoption (themes are self-contained).
- No terminal-emulator config management (shell prompt only).
- Running stateful aliases from the TUI (a subshell can't change the parent's
  cwd/env) — Commands copies command names instead.
