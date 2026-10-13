{
  description = "emerald's NixOS machines";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixos-wsl = {
      url = "github:nix-community/NixOS-WSL/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, ... }@inputs:
    let
      # hostName must match the attribute name: plain `nixos-rebuild switch`
      # picks the flake output by the machine's hostname.
      mkHost = hostName: nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs; };
        modules = [
          ./modules/common.nix
          ./hosts/${hostName}
          { networking.hostName = hostName; }
        ];
      };
    in
    {
      nixosConfigurations = {
        emerald-work = mkHost "emerald-work"; # WSL
        emerald = mkHost "emerald"; # native desktop
      };
    };
}
