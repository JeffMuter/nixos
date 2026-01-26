{ pkgs ? import <nixpkgs> {} }:

pkgs.buildGoModule rec {
  pname = "grofer";
  version = "1.4.0";

  src = pkgs.fetchFromGitHub {
    owner = "pesos";
    repo = "grofer";
    rev = "v1.4.0";
    sha256 = "sha256-klg+CmAzvxQkrlwNgt9jPSg55z10CZN+wXCoueIqxmI=";
  };

  vendorHash = "sha256-jIcD3QTbi/KOpMi5utzG/jYnRj0+i/P6yL29AlV63wI=";

  patches = [
    ./battery-fallback.patch
  ];

  ldflags = [
    "-s"
    "-w"
  ];

  meta = with pkgs.lib; {
    description = "A system monitoring tool written in Go";
    homepage = "https://github.com/pesos/grofer";
    license = licenses.asl20;
    platforms = platforms.linux;
    maintainers = [ ];
  };
}
