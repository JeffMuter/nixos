{ config, lib, pkgs, ... }:

let
  # Automatically import unstable channel
  unstable = import (builtins.fetchTarball {
    url = "https://github.com/NixOS/nixpkgs/archive/nixos-unstable.tar.gz";
  }) { config = config.nixpkgs.config; };

  # Nix User Repository (for charmbracelet packages)
  nur = import (builtins.fetchTarball {
    url = "https://github.com/nix-community/NUR/archive/main.tar.gz";
  }) { inherit pkgs; };

  # Import local grofer package
  grofer = pkgs.callPackage ./grofer.nix {};
in

{
  # sets the version/channel of Nix i want to use
  system.stateVersion = "24.11"; 
  system.autoUpgrade.channel = "https://channels.nixos.org/nixos-24.11";
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  imports = if builtins.pathExists "/proc/sys/fs/binfmt_misc/WSLInterop"
    then  [ ./wsl.nix ./zsh.nix <nixos-wsl/modules> ]
    else  [ 
      #      ./native.nix 
      ./hardware-configuration.nix 
      ./zsh.nix 
      ./native-hyperland.nix ];

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
    clang-tools # tooling
    gcc
    gdb # gnu debugger for C
    fzf
    direnv
    stow
    zsh
    zsh-syntax-highlighting
    zsh-autosuggestions
    thefuck
    git
    neovim-unwrapped
    tmux
    unstable.go
    zig
    python3
    tinygo
    terraform
    azure-cli
    nodejs
    nodePackages.npm
    pkgs.stylua
    unzip
    xclip
    xsel
    ffmpeg                    # used to run video-based commands, project muse is the only current use
    jq
    yt-dlp
    mediamtx
    tmux-mem-cpu-load
    awscli
    docker
    docker-compose
    docker-credential-helpers
    protobuf_28
    protoc-gen-go
    protoc-gen-go-grpc
    hugo 	 	      # blog compiler
    gofumpt
    firebase-tools            # firebase server tooling
    postgresql
    sqlite
    tailwindcss
    ripgrep
    lynx # text web browser.... btw
    cargo #the rust package manager, htmx-lsp depends on this because its built by the primeagen... smh
    git-filter-repo
    nethack
    grofer                    # system monitoring tool
    nur.repos.charmbracelet.crush  # AI terminal assistant
  ];

  virtualisation.docker.enable = true;
  services.gnome.gnome-keyring.enable = true;

  # Fonts
  fonts.packages = with pkgs; [
    scientifica
  ];

  # Allow running dynamically linked binaries (needed for some NUR packages like crush)
  programs.nix-ld.enable = true;

  programs.tmux = {
    enable = true;
    plugins = with pkgs.tmuxPlugins; [
      resurrect
      yank
      sensible
    ];
    extraConfig = ''
      set -g @resurrect-capture-pane-contents 'on'
      set -g @resurrect-strategy-vim 'session'
      set -g status-right "#(~/.tmux/plugins/tmux-powerline/powerline.sh right)"
      set -g status-left-length 40
      set -g status-right-length 80
      '';
  };

  programs.git = {
    enable = true;
    config = {
      user.email = "muterjeffery@gmail.com";
      user.name = "JeffMuter";
    };
  };
}
