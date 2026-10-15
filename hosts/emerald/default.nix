# Native desktop (Hyprland).
{ ... }:
{
  imports = [
    ./hardware-configuration.nix
    ../../modules/desktop-hyprland.nix
  ];

  # Release this machine was first installed with - never bump it.
  system.stateVersion = "24.11";

  # Tailscale client (reach the Ubuntu homelab). Native only: the WSL host
  # uses the Windows Tailscale install, which WSL shares.
  services.tailscale = {
    enable = true;
    useRoutingFeatures = "client";
  };

  boot.loader.grub.enable = true;
  boot.loader.grub.useOSProber = true;
  boot.loader.grub.mirroredBoots = [
    {
      devices = [ "/dev/sda" ];
      path = "/boot";
    }
  ];
}
