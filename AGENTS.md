# AGENTS.md - NixOS configuration

Personal NixOS config for user **`emerald`** (hardcoded everywhere - never change it),
as a **flake** pinned by `flake.lock`. Companion repo: `~/.dotfiles` (user config via
GNU stow; has its own AGENTS.md). Public repo: github.com/JeffMuter/nixos, branch `master`.

## Machines

| host (= hostname) | what | files |
|---|---|---|
| `emerald-work` | Windows / WSL | `hosts/emerald-work/default.nix` |
| `emerald` | native desktop, Hyprland | `hosts/emerald/default.nix`, `hosts/emerald/hardware-configuration.nix` |

`sudo nixos-rebuild switch` picks `flake.nix#<hostname>` (`/etc/nixos` -> `~/nixos`).
There is no runtime WSL detection; each host imports what it needs.

## Layout

```
flake.nix              inputs + one nixosConfigurations entry per host (mkHost "<name>")
flake.lock             pins nixpkgs (nixos-25.11), nixpkgs-unstable, nixos-wsl
modules/common.nix     every machine: packages, user, programs, docker, direnv, tmux, git
modules/zsh.nix        shell: oh-my-zsh, sync functions, startup greeting
modules/desktop-hyprland.nix   Hyprland desktop (native hosts)
hosts/<host>/          per machine: WSL or bootloader settings, stateVersion, hardware
pkgs/                  local derivations (retrosmart-cursors)
templates/devshell/    per-repo dev shell (nix flake init -t ~/nixos#devshell)
scripts/nix-usage      when was each declared package last used
check                  pre-switch check (see below)
install.sh, NEW-MACHINE.md   new machine in one command
.githooks/pre-commit   nixfmt + every host evaluates
.github/workflows/     ci.yml (build both hosts per push), update.yml (weekly lock-bump PR)
```

## Changing the system

1. Edit. **New `.nix` files must be `git add`ed** - flakes only see tracked files.
2. `~/nixos/check` - `nix flake check`, builds **every** host (WSL builds the desktop
   too), then `nvd diff` of running system vs. new build. `--fast`: this host only.
3. `nixos-switch` (= check, show diff, ask y/N, switch) or `sudo nixos-rebuild switch`.
4. Rollback: `sudo nixos-rebuild switch --rollback`.

- Shared packages: `environment.systemPackages` in `modules/common.nix`. Host-only
  things go in `hosts/<host>/` or `modules/desktop-hyprland.nix`.
- Newer versions: `unstable.<pkg>` (go, nodejs, pi-coding-agent, agent-browser, nethack).
- Define each option in **one** place - e.g. `time.timeZone` lives only in
  `common.nix`; duplicates in two modules break the moment one changes.
- `system.stateVersion` is per host and is never bumped.
- Updates are deliberate: `nix flake update` + check, or merge the weekly PR from
  `update.yml`. Nothing changes because "the internet moved".

## Keep the global system small

Global = tools used in every repo or by the dotfiles/agents. Language and cloud
toolchains (terraform, az, aws, clang, gdb, zig, postgres, tailwind, ...) belong in
the repo that uses them, loaded by direnv (`programs.direnv` + nix-direnv):

- new repo: `nix flake init -t ~/nixos#devshell`, list packages, `direnv allow`
- repo with a `shell.nix`: `.envrc` containing `use nix`
- one-off: `nix shell nixpkgs#<tool>`

Before adding a global package ask whether a dev shell fits; `scripts/nix-usage`
shows what is actually used.

## Rules

- **Never run `nix search`** - it crashes this machine. Use `nix-env -qaP | grep <name>`
  or search.nixos.org.
- Don't edit `hosts/*/hardware-configuration.nix` by hand (regenerate with
  `nixos-generate-config --show-hardware-config`).
- Format with `nixfmt <file>`; the pre-commit hook rejects unformatted `.nix` and any
  commit after which a host no longer evaluates (`git commit --no-verify` to bypass once).
- Secrets never go in this repo (it is public). They live in `~/.config/secrets/env`
  and the encrypted bundle in `~/.dotfiles/secrets/`.
- Claude Code comes from npm-global (managed by `~/.dotfiles/bootstrap.sh`), not nix.
- Keep zsh changes minimal (the user may move off zsh). The WSL clipboard alias
  (`win32yank`) and `/mnt/c` PATH lines in `zsh.nix` stay as they are.

## Sync (functions in modules/zsh.nix)

`nix-push`, `nix-pull`, `nix-sync`, `nix-status` and `dot-push`, `dot-pull`, `dot-sync`,
`dot-status`. (Short aliases like `np`/`dp` were removed on purpose.) Push shows
`git status --short` and asks y/N before committing; pull never commits or pushes.
Commit messages: `sync: <hostname> <HH:MM>` for syncs, descriptive otherwise.

## New machine

`NEW-MACHINE.md`: `bash <(curl -fsSL https://raw.githubusercontent.com/JeffMuter/nixos/master/install.sh)`
run twice - then one GitHub login and the secrets passphrase. A new host = copy a
`hosts/` dir, add a `mkHost` line in `flake.nix`.

## Environment notes

- tmux auto-starts in interactive shells; tmux-resurrect/continuum restore sessions
  (`tmux-restore-agents` skill brings agent panes back). `tp` = fzf project picker
  over `~/repos`.
- The startup greeting (default tmux session) shows repo status and `dot-doctor` findings.
- WSL: WSLg display (`DISPLAY=:0`), chromium for pi browser-tools, Windows PATH appended.
