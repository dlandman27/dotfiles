# Port helpers. The interactive TUI lives in bin/ports (`ports`); this file
# only adds the quick non-interactive kill shortcut.

# Kill whatever is listening on a port. Usage: killport 3000
function killport() {
  if [[ -z "$1" ]]; then
    echo "usage: killport <port>"
    return 1
  fi
  ports __kill "$1"
}
