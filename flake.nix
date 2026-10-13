{
  description = "emerald's NixOS machines";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixos-wsl = {
      url = "github:nix-community/NixOS-WSL/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # Imported as plain nix (like the old fetchTarball), not as a flake.
    nur = {
      url = "github:nix-community/NUR";
      flake = false;
    };
  };

  outputs = { nixpkgs, ... }@inputs:
    let
      # hostName must match the attribute name: plain `nixos-rebuild switch`
      # picks the flake output by the machine's hostname.
      mkHost = hostName: isWSL: extraModules: nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs isWSL; };
        modules = [ ./configuration.nix { networking.hostName = hostName; } ] ++ extraModules;
      };
    in
    {
      nixosConfigurations = {
        emerald-work = mkHost "emerald-work" true [ inputs.nixos-wsl.nixosModules.default ];
        emerald = mkHost "emerald" false [ ];
      };
    };
}
