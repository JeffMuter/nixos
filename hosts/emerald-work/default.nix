# Windows / WSL machine.
{ inputs, ... }:
{
  imports = [ inputs.nixos-wsl.nixosModules.default ];

  # Release this machine was first installed with - never bump it.
  system.stateVersion = "24.11";

  wsl.enable = true;
  wsl.defaultUser = "emerald";

  # WSLg's X server socket (/tmp/.X11-unix/X0) exists but DISPLAY isn't exported,
  # so GUI apps (chromium for pi's browser-tools) had nowhere to draw.
  environment.sessionVariables.DISPLAY = ":0";
}
