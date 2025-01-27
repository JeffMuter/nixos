{ config, lib, pkgs, ... }:

{
  # sets the version/channel of Nix i want to use
  system.stateVersion = "24.11"; 
  system.autoUpgrade.channel = "https://channels.nixos.org/nixos-24.11";
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  imports = if builtins.pathExists "/proc/sys/fs/binfmt_misc/WSLInterop"
    then  [ ./wsl.nix ./zsh.nix <nixos-wsl/modules> ]
    else  [ ./native.nix ./hardware-configuration.nix ./zsh.nix ];

  users.users.emerald = {
    isNormalUser = true;
    extraGroups = [ "wheel" "video" "input" "users" ];
    shell = pkgs.zsh;
  };

  nixpkgs.config.allowUnfree = true; 

  # install and enable these packages
  environment.systemPackages = with pkgs; [
    gcc
    stow
    zsh
    zsh-syntax-highlighting
    zsh-autosuggestions
    thefuck
    git
    neovim-unwrapped
    tmux
    go
    zig
    tinygo
    terraform
    azure-cli
    nodejs
    pkgs.stylua
    unzip
    xclip
    xsel
    sqlc
    ffmpeg                    # used to run video-based commands, project muse is the only current use
    mediamtx
    protobuf_28
    protoc-gen-go
    protoc-gen-go-grpc
    hugo 	 	      # blog compiler
    firebase-tools            # firebase server tooling
    postgresql
    sqlite
    tailwindcss
    ripgrep
    lynx # text web browser.... btw
  ];

  programs.tmux = {
    enable = true;
    plugins = with pkgs.tmuxPlugins; [
      resurrect
      yank
      sensible
    ];
  };

  programs.git = {
    enable = true;
    config = {
      user.email = "muterjeffery@gmail.com";
      user.name = "JeffMuter";
    };
  };
}
