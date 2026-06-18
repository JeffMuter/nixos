{ stdenv, lib, fetchurl, autoPatchelfHook }:

# LightPanda — lightweight headless browser used by agent-browser's
# `--engine lightpanda`. Upstream ships only a devShell flake (Zig build) and
# prebuilt binaries; we use the prebuilt x86_64 Linux binary to avoid a
# RAM-heavy source compile. The `nightly` tag is rolling, so the hash below is
# pinned — to bump, run:
#   nix-prefetch-url https://github.com/lightpanda-io/browser/releases/download/nightly/lightpanda-x86_64-linux
# and replace `sha256` with the printed value.
stdenv.mkDerivation {
  pname = "lightpanda";
  version = "nightly";

  src = fetchurl {
    url = "https://github.com/lightpanda-io/browser/releases/download/nightly/lightpanda-x86_64-linux";
    sha256 = "1ibj5l1v5k5j8fjha4wdmy3jrh2q63fggyi3bcxmpzb88a9hq30f";
  };

  # The download is a bare ELF executable, not an archive.
  dontUnpack = true;
  dontBuild = true;
  dontConfigure = true;

  nativeBuildInputs = [ autoPatchelfHook ];
  buildInputs = [ stdenv.cc.cc.lib ];

  installPhase = ''
    runHook preInstall
    install -Dm755 $src $out/bin/lightpanda
    runHook postInstall
  '';

  meta = with lib; {
    description = "Lightweight headless browser for AI and automation";
    homepage = "https://lightpanda.io";
    license = licenses.agpl3Only;
    platforms = [ "x86_64-linux" ];
    mainProgram = "lightpanda";
  };
}
