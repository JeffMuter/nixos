{ config, lib, pkgs, ... }:

{
  # sets the version/channel of Nix i want to use
  system.stateVersion = "24.11"; 
  system.autoUpgrade.channel = "https://channels.nixos.org/nixos-24.11";
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  imports = [
    # include NixOS-WSL modules
    <nixos-wsl/modules>
  ];

  # settings to enable and default user if using wsl
  wsl.enable = true;
  wsl.defaultUser = "emerald";

  # enables, then sets zsh to the default shell for the system
  programs.zsh.enable = true;

  users.users.emerald = {
    isNormalUser = true;
    extraGroups = [ "wheel" "video" "input" "users" ];
    shell = pkgs.zsh;
  };

  # install and enable these packages
  environment.systemPackages = with pkgs; [
    gcc
    stow
    zsh
    git
    neovim-unwrapped
    tmux
    go
    nodejs
    pkgs.stylua
    unzip
    xclip
    xsel
    sqlc
    hugo #blog compiler
    firebase-tools #firebase server tooling
    postgresql
    sqlite
    tailwindcss
  ];
  programs.tmux = {
    enable = true;
    plugins = with pkgs.tmuxPlugins; [
      resurrect
      yank
      sensible
    ];
  };

  services.xserver = {
    enable = true;
  };
}
