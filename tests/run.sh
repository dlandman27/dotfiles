#!/usr/bin/env bash
# Zero-dependency test suite for the dotfiles repo.
# Run with:  ./tests/run.sh   (or  make test)
#
# Covers: shell-script syntax, every prompt theme, the theme loader, the `dot`
# TUI's pure helper functions, install.sh symlinking, and git config.

set -uo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

PASS=0
FAIL=0
RED=$'\033[31m'; GREEN=$'\033[32m'; DIM=$'\033[2m'; BOLD=$'\033[1m'; RESET=$'\033[0m'

have() { command -v "$1" &>/dev/null; }

# ok "<description>" <command...>   — passes if the command exits 0.
ok() {
  local desc="$1"; shift
  if "$@" >/dev/null 2>&1; then
    PASS=$((PASS+1)); printf "  ${GREEN}✓${RESET} %s\n" "$desc"
  else
    FAIL=$((FAIL+1)); printf "  ${RED}✗ %s${RESET}\n" "$desc"
  fi
}

# fails "<description>" <command...> — passes if the command exits NON-zero.
fails() {
  local desc="$1"; shift
  if "$@" >/dev/null 2>&1; then
    FAIL=$((FAIL+1)); printf "  ${RED}✗ %s (expected failure)${RESET}\n" "$desc"
  else
    PASS=$((PASS+1)); printf "  ${GREEN}✓${RESET} %s\n" "$desc"
  fi
}

# contains "<description>" "<needle>" <command...> — passes if stdout has needle.
contains() {
  local desc="$1" needle="$2"; shift 2
  local out; out="$("$@" 2>/dev/null)"
  if [[ "$out" == *"$needle"* ]]; then
    PASS=$((PASS+1)); printf "  ${GREEN}✓${RESET} %s\n" "$desc"
  else
    FAIL=$((FAIL+1)); printf "  ${RED}✗ %s${RESET} ${DIM}(missing: %s)${RESET}\n" "$desc" "$needle"
  fi
}

group() { printf "\n${BOLD}%s${RESET}\n" "$1"; }

# ── shell-script syntax ───────────────────────────────────────────
group "shell-script syntax"
ok "install.sh parses"   bash -n install.sh
ok "bin/dot parses"      bash -n bin/dot
ok "bin/sim parses"      bash -n bin/sim
ok "tests/run.sh parses" bash -n tests/run.sh

if have zsh; then
  group "zsh module syntax"
  for f in zsh/.zshrc zsh/history.zsh zsh/aliases.zsh zsh/ai.zsh zsh/theme.zsh; do
    ok "zsh -n $f" zsh -n "$f"
  done
else
  group "zsh module syntax"
  printf "  ${DIM}- skipped (zsh not installed)${RESET}\n"
fi

# ── themes ────────────────────────────────────────────────────────
if have zsh; then
  group "prompt themes"
  count=$(ls zsh/themes/*.zsh 2>/dev/null | wc -l | tr -d ' ')
  ok "ships at least 20 themes (found $count)" test "$count" -ge 20

  # Every theme: parses, and sets a non-empty PROMPT when sourced.
  for tf in zsh/themes/*.zsh; do
    name="$(basename "$tf" .zsh)"
    ok "theme '$name' parses" zsh -n "$tf"
    ok "theme '$name' sets PROMPT" zsh -fc "
      setopt prompt_subst; source '$tf'
      [[ -n \"\${PROMPT:-}\" ]]"
  done

  group "theme loader (theme.zsh)"
  ok "loads a valid theme" zsh -fc "
    DOTFILES_THEME=minimal; source zsh/theme.zsh; [[ -n \"\$PROMPT\" ]]"
  ok "unknown theme does not error" zsh -fc "
    DOTFILES_THEME=does-not-exist; source zsh/theme.zsh"
fi

# ── dot TUI helpers (sourced, no gum needed) ──────────────────────
group "dot TUI helpers"
ok "bin/dot is executable" test -x bin/dot

# settings_get / settings_set round-trip against a sandbox file.
ok "settings_set then settings_get round-trips" bash -c '
  set -euo pipefail
  source bin/dot
  SETTINGS="$(mktemp)"
  settings_set DOTFILES_THEME agnoster
  [ "$(settings_get DOTFILES_THEME robbyrussell)" = "agnoster" ]
  settings_set DOTFILES_THEME minimal   # overwrite, not append
  [ "$(settings_get DOTFILES_THEME robbyrussell)" = "minimal" ]
  [ "$(grep -c "^DOTFILES_THEME=" "$SETTINGS")" -eq 1 ]
  rm -f "$SETTINGS"'

ok "settings_get returns default when unset" bash -c '
  set -euo pipefail
  source bin/dot
  SETTINGS="$(mktemp)"; rm -f "$SETTINGS"
  [ "$(settings_get NOPE fallback)" = "fallback" ]'

contains "list_themes includes built-ins" "robbyrussell" \
  bash -c 'source bin/dot; list_themes'
contains "list_themes includes minimal" "minimal" \
  bash -c 'source bin/dot; list_themes'

if have zsh; then
  contains "cmd_definition resolves an alias" "git status" \
    bash -c 'source bin/dot; cmd_definition gst'
  contains "cmd_definition resolves a function" "gh pr" \
    bash -c 'source bin/dot; cmd_definition gprc'

  # fzf preview hooks: the script re-execs itself to render a row.
  ok "__render_theme prints a prompt" bash -c '[ -n "$(bash bin/dot __render_theme minimal)" ]'
  contains "__render_cmd resolves a command" "git status" bash bin/dot __render_cmd gst
fi

# ── install.sh symlinking (sandboxed HOME) ────────────────────────
group "install.sh"
ok "links configs into a sandbox HOME" bash -c '
  set -euo pipefail
  tmp="$(mktemp -d)"
  HOME="$tmp" bash install.sh >/dev/null 2>&1
  [ -L "$tmp/.zshrc" ] && [ -L "$tmp/.gitconfig" ] && [ -L "$tmp/.gitignore_global" ]
  # backs up a pre-existing real file
  rm -f "$tmp/.zshrc"; echo real > "$tmp/.zshrc"
  HOME="$tmp" bash install.sh >/dev/null 2>&1
  [ -f "$tmp/.zshrc.bak" ] && [ -L "$tmp/.zshrc" ]
  rm -rf "$tmp"'

# ── git config ────────────────────────────────────────────────────
group "git config"
ok "gitconfig parses" git config -f git/.gitconfig --list
contains "sets core.excludesfile" "gitignore_global" \
  git config -f git/.gitconfig --get core.excludesfile

# ── zsh aliases / functions defined ───────────────────────────────
if have zsh; then
  group "aliases & functions"
  ok "dotfiles() defined"  zsh -fc "source zsh/aliases.zsh; typeset -f dotfiles >/dev/null"
  ok "zhelp() defined"     zsh -fc "source zsh/aliases.zsh; typeset -f zhelp >/dev/null"
  ok "gst alias defined"   zsh -fc "source zsh/aliases.zsh; alias gst >/dev/null"
  ok "gprc() defined"      zsh -fc "source zsh/ai.zsh; typeset -f gprc >/dev/null"
  ok "gcai() defined"      zsh -fc "source zsh/ai.zsh; typeset -f gcai >/dev/null"
  ok "ask() defined"       zsh -fc "source zsh/ai.zsh; typeset -f ask >/dev/null"
fi

# ── summary ───────────────────────────────────────────────────────
printf "\n${BOLD}%d passed, %d failed${RESET}\n" "$PASS" "$FAIL"
[ "$FAIL" -eq 0 ]
