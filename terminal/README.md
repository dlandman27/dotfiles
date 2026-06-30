# Apple Terminal profiles

Drop exported Terminal profiles here as `*.terminal` files. `install.sh`
imports every one it finds and makes the first one Terminal's default.

## Exporting your current look

1. **Terminal → Settings → Profiles** — set the background color, font, the
   16 ANSI colors, cursor, window opacity, etc.
2. Select that profile → the gear ⚙️ at the bottom of the profile list →
   **Export…**
3. Save it into this folder, e.g. `terminal/Dylan.terminal`. The filename
   (minus `.terminal`) is the profile name `install.sh` will set as default.

## Applying on a new machine

`./install.sh` (macOS only) does this for you:

- `open`s each `*.terminal` file, which registers it under
  **Settings → Profiles**, then
- sets the first profile as both the **default** and **startup** window
  settings via `defaults write com.apple.Terminal`.

Restart Terminal afterward for the default to take effect.

> Heads-up: a `.terminal` file is a binary plist, so git can't show readable
> diffs when you tweak a color — re-export and commit the new blob.
