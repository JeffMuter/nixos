{ pkgs ? import <nixpkgs> {} }:

pkgs.stdenv.mkDerivation rec {
  pname = "retrosmart-x11-cursors";
  version = "3.1a";

  src = pkgs.fetchFromGitHub {
    owner = "mdomlop";
    repo = "retrosmart-x11-cursors";
    rev = "3.1a";
    sha256 = "0pij5ybd7bfiiglwwkppqd6227hf10bky8z8ksymmvdrc27w98mk";
  };

  nativeBuildInputs = with pkgs; [
    imagemagick
    xorg.xcursorgen
  ];

  # The Makefile expects these tools to be available
  buildPhase = ''
    make
  '';

  installPhase = ''
    make install DESTDIR=$out PREFIX=""
    # Ensure the cursors are in the expected location
    mkdir -p $out/share/icons
    if [ -d $out/icons ]; then
      mv $out/icons/* $out/share/icons/
      rmdir $out/icons
    fi
  '';

  meta = with pkgs.lib; {
    description = "An old-fashioned look X11 cursor theme";
    homepage = "https://github.com/mdomlop/retrosmart-x11-cursors";
    license = licenses.gpl3;
    platforms = platforms.linux;
    maintainers = [ ];
  };
}
