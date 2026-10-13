{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:

let
  # Unstable nixpkgs, pinned in flake.lock
  unstable = import inputs.nixpkgs-unstable {
    inherit (pkgs.stdenv.hostPlatform) system;
    config = config.nixpkgs.config;
  };

in

{
  time.timeZone = "America/New_York";
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  # Shared by every host. Per-machine bits live in hosts/<hostname>/.
  imports = [ ./zsh.nix ];

  users.users.emerald = {
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "video"
      "audio"
      "input"
      "users"
      "docker"
    ];
    shell = pkgs.zsh;
    uid = 1000; # Explicitly set to match WSL expectation
    home = "/home/emerald";
  };

  nixpkgs.config.allowUnfree = true;

  # install and enable these packages
  environment.systemPackages = with pkgs; [
    pay-respects
    gcc
    fzf
    stow
    gh # one-time GitHub login on a new machine (install.sh)
    nvd # ~/nixos/check: package diff before switching
    nixfmt # .githooks/pre-commit (nixos)
    gitleaks # .githooks/pre-commit (dotfiles)
    shellcheck # .githooks/pre-commit (dotfiles)
    age # secrets-backup / secrets-restore (dotfiles)
    neovim-unwrapped
    tree-sitter
    tmux
    unstable.go
    python3
    unstable.nodejs
    unstable.pi-coding-agent
    unstable.agent-browser
    pkgs.stylua
    unzip
    xclip
    jq
    yt-dlp # videoclear - until it has its own dev shell
    docker-credential-helpers
    gofumpt
    firebase-tools # jeffmuter-portfolio deploys - until it has its own dev shell
    sqlite
    ripgrep
    cargo # the rust package manager, htmx-lsp depends on this because its built by the primeagen... smh
    chromium # pi browser-tools skill (CDP on :9222); shows via WSLg on WSL
    zk
    unstable.nethack
  ];

  # Per-project dev shells: a repo's .envrc (`use flake` / `use nix`) loads its
  # toolchain on cd. nix-direnv caches it and protects it from garbage collection.
  # New repo: nix flake init -t ~/nixos#devshell && direnv allow
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

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
  # Every level is listed: tmpfiles creates missing parents as root, and a
  # root-owned ~/.config on a fresh machine makes stow (bootstrap.sh) fail.
  systemd.tmpfiles.rules = [
    "d /home/emerald/.config 0755 emerald users -"
    "d /home/emerald/.config/systemd 0755 emerald users -"
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
    config.safe.directory = [
      "/etc/nixos"
      "/home/emerald/nixos"
    ];
  };
}
