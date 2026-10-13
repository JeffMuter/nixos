{
  description = "dev shell for this repo";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";

  outputs =
    { nixpkgs, ... }:
    let
      pkgs = nixpkgs.legacyPackages.x86_64-linux;
    in
    {
      devShells.x86_64-linux.default = pkgs.mkShell {
        # this repo's toolchain - loaded by direnv when you cd in
        packages = with pkgs; [
          # go
          # terraform
          # postgresql
        ];
      };
    };
}
