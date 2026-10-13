{ config, lib, pkgs, inputs, ... }:

let
  # Unstable nixpkgs, pinned in flake.lock
  unstable = import inputs.nixpkgs-unstable {
    inherit (pkgs.stdenv.hostPlatform) system;
    config = config.nixpkgs.config;
  };

  # Import local grofer package
  grofer = pkgs.callPackage ../pkgs/grofer.nix {};
in

{
  time.timeZone = "America/New_York";
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Shared by every host. Per-machine bits live in hosts/<hostname>/.
  imports = [ ./zsh.nix ];

  users.users.emerald = {
    isNormalUser = true;
    extraGroups = [ "wheel" "video" "audio" "input" "users" "docker" ];
    shell = pkgs.zsh;
    uid = 1000;  # Explicitly set to match WSL expectation
    home = "/home/emerald";
  };

  nixpkgs.config.allowUnfree = true; 

  # install and enable these packages
  environment.systemPackages = with pkgs; [
    clang # for C
    pay-respects
    clang-tools # tooling
    gcc
    gdb # gnu debugger for C
    fzf
    direnv
    stow
    gh                        # one-time GitHub login on a new machine (install.sh)
    age                       # secrets-backup / secrets-restore (dotfiles)
    neovim-unwrapped
    tree-sitter
    tmux
    unstable.go
    unstable.zig
    unstable.zls
    python3
    terraform
    azure-cli
    unstable.nodejs
    unstable.pi-coding-agent
    unstable.agent-browser
    pkgs.stylua
    unzip
    xclip
    xsel
    jq
    yt-dlp
    tmux-mem-cpu-load
    awscli
    docker
    docker-compose
    docker-credential-helpers
    gofumpt
    firebase-tools            # firebase server tooling
    postgresql
    sqlite
    tailwindcss
    ripgrep
    cargo #the rust package manager, htmx-lsp depends on this because its built by the primeagen... smh
    git-filter-repo
    grofer                    # system monitoring tool
    chromium                  # pi browser-tools skill (CDP on :9222); shows via WSLg on WSL
    zk
    unstable.nethack
  ];

  virtualisation.docker.enable = true;
  services.gnome.gnome-keyring.enable = true;

  # Fonts
  fonts.packages = with pkgs; [
    scientifica
  ];

  # Allow running dynamically linked binaries (prebuilt tools, mason LSPs)
  programs.nix-ld.enable = true;

  # tmux-continuum's systemd_enable.sh writes tmux.service via `>` before it
  # ever runs its own `mkdir -p`, so it silently fails if this dir is missing.
  systemd.tmpfiles.rules = [
    "d /home/emerald/.config/systemd/user 0755 emerald users -"
  ];

  programs.tmux = {
    enable = true;
    # resurrect/continuum are wired up manually below (options set, *then*
    # run-shell) instead of via `plugins`, because nix's `programs.tmux`
    # module always renders `extraConfig` after the `plugins` run-shell
    # lines - continuum reads @continuum-boot on its very first line, before
    # extraConfig has a chance to set it, so the option is always seen as
    # unset/off when loaded via `plugins`.
    plugins = with pkgs.tmuxPlugins; [
      yank
      sensible
    ];
    extraConfig = ''
      set -g @resurrect-capture-pane-contents 'on'
      set -g @resurrect-strategy-vim 'session'
      set -g @continuum-restore 'on'
      set -g @continuum-save-interval '5'
      set -g @continuum-boot 'on'
      set -g @continuum-systemd-start-cmd 'new-session -d -s default'

      run-shell ${pkgs.tmuxPlugins.resurrect}/share/tmux-plugins/resurrect/resurrect.tmux
      run-shell ${pkgs.tmuxPlugins.continuum}/share/tmux-plugins/continuum/continuum.tmux

      set -g status-left-length 40
      set -g status-right-length 80
      '';
  };

  # Identity, aliases and merge tool live in ~/.dotfiles/git/.gitconfig.
  # safe.directory lets root (nixos-rebuild) read this user-owned repo.
  programs.git = {
    enable = true;
    config.safe.directory = [ "/etc/nixos" "/home/emerald/nixos" ];
  };
}

