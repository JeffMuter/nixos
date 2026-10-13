# Native desktop (Hyprland).
{ ... }:
{
  imports = [
    ./hardware-configuration.nix
    ../../modules/desktop-hyprland.nix
  ];

  # Release this machine was first installed with - never bump it.
  system.stateVersion = "24.11";

  boot.loader.grub.enable = true;
  boot.loader.grub.useOSProber = true;
  boot.loader.grub.mirroredBoots = [
    {
      devices = [ "/dev/sda" ];
      path = "/boot";
    }
  ];
}
