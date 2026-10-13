#!/usr/bin/env bash
# New machine setup. Run the same command twice (see NEW-MACHINE.md):
#
#   bash <(curl -fsSL https://raw.githubusercontent.com/JeffMuter/nixos/master/install.sh) [host]
#
# Phase 1 - fresh NixOS-WSL, logged in as the default "nixos" user:
#   installs the pinned system for <host> (default emerald-work), which creates
#   user emerald, then tells you how to restart WSL into that user.
# Phase 2 - logged in as emerald (WSL or native):
#   one GitHub login, clones ~/nixos and ~/.dotfiles, points /etc/nixos at
#   ~/nixos, then hands over to ~/.dotfiles/bootstrap.sh (stow, secrets, tools).
#
# Use `bash <(curl ...)`, not `curl ... | bash`: the logins need your terminal.
set -euo pipefail

REPO=JeffMuter/nixos
DOTREPO=JeffMuter/.dotfiles
HOST=${1:-emerald-work}
URL="https://raw.githubusercontent.com/$REPO/master/install.sh"
FLAKES="extra-experimental-features = nix-command flakes"

die() { echo "install: $*" >&2; exit 1; }

if [[ "$(id -un)" != emerald ]]; then
  # ---- phase 1 ---------------------------------------------------------------
  [[ -e /proc/sys/fs/binfmt_misc/WSLInterop ]] \
    || die "phase 1 is for a fresh NixOS-WSL. Native machine: follow NEW-MACHINE.md (hardware config first)."
  echo "==> installing the pinned system for '$HOST' (takes a while the first time)"
  # NixOS-WSL's documented way to switch the default user: build with `boot`,
  # then restart WSL (a `switch` can leave the new user misconfigured).
  sudo env NIX_CONFIG="$FLAKES" nixos-rebuild boot --flake "github:$REPO#$HOST"
  distro=${WSL_DISTRO_NAME:-NixOS}
  cat <<EOF

==> Phase 1 done. Close this window, then in PowerShell run:

    wsl -t $distro
    wsl -d $distro --user root exit
    wsl -t $distro

Open $distro again (you are now 'emerald') and run the same command again:

    bash <(curl -fsSL $URL)

EOF
  exit 0
fi

# ---- phase 2 -----------------------------------------------------------------
command -v gh >/dev/null || die "gh not found - phase 1 (the system install) did not finish"

echo "==> GitHub login (once per machine; needed for the private dotfiles repo)"
gh auth status >/dev/null 2>&1 || gh auth login --hostname github.com --git-protocol https --web
gh auth setup-git

echo "==> cloning repos"
[[ -d "$HOME/nixos/.git" ]]    || git clone "https://github.com/$REPO.git" "$HOME/nixos"
[[ -d "$HOME/.dotfiles/.git" ]] || git clone "https://github.com/$DOTREPO.git" "$HOME/.dotfiles"

# plain `sudo nixos-rebuild switch` reads /etc/nixos/flake.nix#<hostname>
if [[ "$(readlink /etc/nixos || true)" != "$HOME/nixos" ]]; then
  echo "==> /etc/nixos -> ~/nixos"
  if [[ -e /etc/nixos && ! -L /etc/nixos ]]; then sudo mv /etc/nixos /etc/nixos.orig; fi
  sudo ln -sfn "$HOME/nixos" /etc/nixos
fi

exec "$HOME/.dotfiles/bootstrap.sh"
