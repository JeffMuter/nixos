# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running 'nixos-help').
{pkgs, config, ... }:
{
  # Bootloader.
  boot.loader.grub.enable = true;
  boot.loader.grub.mirroredBoots = [
   { 
      devices = [ "/dev/sda" ]; 
      path = "/boot"; 
   }
  ];
  boot.loader.grub.useOSProber = true;
  networking.hostName = "nixos"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";
  # Enable networking
  networking.networkmanager.enable = true;
  # Set your time zone.
  time.timeZone = "America/New_York";
  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  services.udev.packages = with pkgs; [ platformio-core.udev ];

  # services.xserver = {
  #       enable = true;
  #       windowManager.i3 = {
  #         enable = true;
  #       };
  # };

  # sets up hyperland & wayland as display server & window manager
  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };
  
  services.displayManager = {
    defaultSession = "hyprland";
    sddm = {
      enable = true;
      wayland.enable = true;
    };
  };

  # Fix the deprecated displayManager option
  # services.displayManager.defaultSession = "none+i3";
  
  # Import the unstable nixpkgs just for cursor
  nixpkgs.overlays = [
    (final: prev: {
      # Specifically pull Cursor from unstable with proper unfree config
      code-cursor = (import (fetchTarball "https://github.com/NixOS/nixpkgs/archive/nixos-unstable.tar.gz") {
        inherit (pkgs) system;
        config.allowUnfree = true;  # This is the key fix
      }).code-cursor;
    })
  ];

  xdg.portal = {
    enable = true;
    extraPortals = [ 
      pkgs.xdg-desktop-portal-hyprland  # Hyprland-specific portal
      pkgs.xdg-desktop-portal-gtk       # GTK portal for fallback
    ];
    # Fix the portal configuration warning
    config.common.default = "*";
  };
  
  services.flatpak.enable = true; 
  # Define a user account. Don't forget to set a password with 'passwd'.
  users.users.emerald = {
    isNormalUser = true;
    description = "emerald";
    extraGroups = [ "networkmanager" "wheel" "dialout" "plugdev" ];
    packages = with pkgs; [];
  };
  # Enable automatic login for the user.
  services.getty.autologinUser = "emerald";
  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;
  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    pavucontrol
    alsa-utils
    ghostty

    # i3 # window manager with x11
    # flameshot # x11 display server's screenshot tool
    # for wayland/hyprland specifically
    wofi
    waybar
    hyprpaper
    grim
    slurp
    wl-clipboard
    mako # notifications
    swaylock
    swayidle
    wlsunset
    # end of wayland/hyprland
    arduino
    arduino-cli
    platformio
    python3
    python3Packages.pip
    alacritty
    firefox
    obsidian
    code-cursor
    appimage-run
    fuse
    brightnessctl
    light
  ];

  # Environment variables for Wayland compatibility
  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";      # Electron apps use Wayland
    MOZ_ENABLE_WAYLAND = "1";  # Firefox uses Wayland
  };

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };
  # List services that you want to enable:
  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;
  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;
  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It's perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.11"; # Did you read the comment?
}
