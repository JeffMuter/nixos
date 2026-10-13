# New machine

Everything is pinned (`flake.lock`) and every secret is in the encrypted bundle
in the dotfiles repo, so a new machine ends up identical to the old one.
You need: **your GitHub login** and **your secrets passphrase**. Nothing else.

## Windows (WSL) — host `emerald-work`

1. **Install NixOS-WSL** — download `nixos.wsl` from
   <https://github.com/nix-community/NixOS-WSL/releases> and double-click it
   (or `wsl --install --from-file nixos.wsl`). Open it; you are user `nixos`.

2. **Install the system:**
   ```sh
   bash <(curl -fsSL https://raw.githubusercontent.com/JeffMuter/nixos/master/install.sh)
   ```
   It builds the pinned system and prints three `wsl` commands. Run them in
   PowerShell; they restart WSL as user `emerald`.

3. **Same command again**, now as `emerald`:
   ```sh
   bash <(curl -fsSL https://raw.githubusercontent.com/JeffMuter/nixos/master/install.sh)
   ```
   - GitHub login opens in the browser (once).
   - It clones `~/nixos` and `~/.dotfiles` and runs `~/.dotfiles/bootstrap.sh`.
   - Bootstrap asks for your **secrets passphrase** once: SSH key, API keys,
     Claude / pi / gccli logins come back.

4. **Done** when bootstrap ends with `dot-doctor: clean` and `bootstrap: done`.
   Open a new terminal.

A *second* machine running alongside this one (not a replacement) should get its
own name: `cp -r hosts/emerald-work hosts/emerald-work2`, add
`emerald-work2 = mkHost "emerald-work2";` to `flake.nix`, push, and pass that
name as the last argument to `install.sh` in step 2.

## Native desktop — host `emerald`

1. Install NixOS from the ISO, creating user **`emerald`**.
2. Put this machine's hardware config in the repo and push it:
   `nixos-generate-config --show-hardware-config` →
   `hosts/emerald/hardware-configuration.nix` (check the grub device in
   `hosts/emerald/default.nix` too).
3. `sudo nixos-rebuild switch --flake github:JeffMuter/nixos#emerald`, reboot.
4. Run step 3 of the WSL list above (the `install.sh` line, as `emerald`).

## If something goes wrong

- **Bootstrap lists "cannot stow … over existing target"** — a real file is where
  a link should go. Move it aside (or copy what you want into the repo), re-run
  `~/.dotfiles/bootstrap.sh`. It is always safe to re-run.
- **Wrong passphrase** — re-run `~/.dotfiles/bootstrap.sh`.
- **Anything else** — `dot-doctor` says what is missing; re-running bootstrap fixes
  most of it.

## Keeping the next move painless

- After changing a secret (`~/.config/secrets/env`, SSH key) run `secrets-backup`,
  then `dot-push`. `dot-doctor` (and the shell greeting) reminds you.
- New config file somewhere in `~`? `dot-doctor` will list it: stow it, or add it
  to `~/.dotfiles/unmanaged`.
- System rebuild: `sudo nixos-rebuild switch` (pinned; nothing changes unless you
  update `flake.lock` on purpose).
