# Omarchy config backup

Snapshot of the Omarchy desktop configuration, captured **2026-11-17** from
Omarchy `4.5.0-3`.

Everything here mirrors its live location:

| This directory | Restores to |
| --- | --- |
| `config/hypr/` | `~/.config/hypr/` |
| `config/omarchy/` | `~/.config/omarchy/` |
| `config/alacritty/`, `config/kitty/`, `config/foot/`, `config/ghostty/` | `~/.config/<terminal>/` |
| `config/git/`, `config/autostart/`, `config/environment.d/`, `config/fontconfig/`, `config/systemd/`, `config/*.toml`, `config/mimeapps.list`, etc. | `~/.config/` |
| `home/` | `~/` |
| `state/omarchy/` | `~/.local/state/omarchy/` |

Included: Hyprland keybindings/monitors/look-and-feel, Omarchy `shell.json`
(bar layout, widgets, idle/lock timing), custom menu extensions, hooks, the
`khanh.menu` shell plugin, custom `apple` / `apple-dark` themes (including
backgrounds), terminal configs, autostart entries, systemd user units and
Omarchy toggles/workspace layouts.

**Deliberately excluded:** browser profiles, Signal data, SSH/GPG private keys,
keyrings, credentials/tokens, caches, notification/clipboard history, and the
generated `~/.local/state/omarchy/current/theme/` tree (it is recreated when
you re-apply a theme).

## Hardware notes

- [Mac mini (2018): Bluetooth keyboard at the LUKS prompt](mac-mini-2018-omarchy-bluetooth-boot.md) — early-boot Bluetooth setup for the Intel + T2 Mac mini.

## Restore on a fresh install

1. Install Omarchy, log in, and clone this repo's `linux` branch.
2. Copy the configs back:

   ```sh
   cd ~/dotfiles   # linux branch
   cp -a omarchy/config/hypr/.      ~/.config/hypr/
   cp -a omarchy/config/omarchy/.   ~/.config/omarchy/
   cp -a omarchy/config/alacritty/. ~/.config/alacritty/
   cp -a omarchy/config/kitty/.     ~/.config/kitty/
   cp -a omarchy/config/foot/.      ~/.config/foot/
   cp -a omarchy/config/ghostty/.   ~/.config/ghostty/
   cp -a omarchy/config/git/.       ~/.config/git/
   cp -a omarchy/config/autostart/.    ~/.config/autostart/
   cp -a omarchy/config/environment.d/. ~/.config/environment.d/
   cp -a omarchy/config/fontconfig/.   ~/.config/fontconfig/
   cp -a omarchy/config/systemd/.   ~/.config/systemd/
   cp -a omarchy/config/*.toml omarchy/config/mimeapps.list omarchy/config/chromium-flags.conf ~/.config/
   cp -a omarchy/home/.bashrc omarchy/home/.bash_profile omarchy/home/.XCompose ~/
   cp -a omarchy/state/omarchy/. ~/.local/state/omarchy/
   ```

3. Re-apply the theme so generated theme state is rebuilt:

   ```sh
   omarchy theme set apple-dark
   omarchy restart shell
   ```

4. Re-enable the user services that were enabled on the old machine (the
   `*.wants/` symlinks are generated state, so they are not stored here):

   ```sh
   systemctl --user enable --now \
     pipewire-pulse.service pipewire-pulse.socket \
     omarchy-recover-internal-monitor.service bt-agent.service \
     omarchy-crash-watch.service omarchy-fcitx5.service \
     omarchy-migrate-notify.service omarchy-sleep-lock.service \
     owed.service superwhisper.service mac-style.timer
   ```

   The `superwhisper-panel` plugin symlink under `~/.config/omarchy/plugins/`
   is also left out — reinstalling Superwhisper recreates it.

5. Log out and back in (or reboot) for all services and XCompose changes to
   take effect.

## Caution on version changes

This is a snapshot of one Omarchy version. After a major Omarchy update, do
not blindly overwrite fresh defaults — commands and config keys get renamed
between releases. Compare against the new defaults first (`omarchy refresh
config <file>` backs up the current file before resetting) and re-apply only
your own changes where needed.
