# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running 'nixos-help').
{ pkgs, config, ... }:

let
  retrosmart-cursors = pkgs.callPackage ../pkgs/retrosmart-cursors.nix { };
in
{
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";
  # Enable networking
  networking.networkmanager.enable = true;
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

  # Enable dconf for GTK applications
  programs.dconf.enable = true;

  xdg.portal = {
    enable = true;
    extraPortals = [
      pkgs.xdg-desktop-portal-hyprland # Hyprland-specific portal
      pkgs.xdg-desktop-portal-gtk # GTK portal for fallback
    ];
    # Fix the portal configuration warning
    config.common.default = "*";
  };

  services.flatpak.enable = true;
  # Define a user account. Don't forget to set a password with 'passwd'.
  users.users.emerald = {
    isNormalUser = true;
    description = "emerald";
    extraGroups = [
      "networkmanager"
      "wheel"
      "dialout"
      "plugdev"
    ];
    packages = with pkgs; [ ];
  };
  # Enable automatic login for the user.
  services.getty.autologinUser = "emerald";
  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    pavucontrol
    alsa-utils
    ghostty

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
    python3
    python3Packages.pip
    appimage-run
    fuse
    brightnessctl # assumed correct over `light`; remove if wrong
    retrosmart-cursors
    gsettings-desktop-schemas
    libsForQt5.qt5.qttools
  ];

  # Environment variables for Wayland compatibility
  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1"; # Electron apps use Wayland
    XDG_CURRENT_DESKTOP = "Hyprland";
    XCURSOR_THEME = "retrosmart-xcursor-white";
    XCURSOR_SIZE = "33";
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
}
