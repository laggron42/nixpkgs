{
  lib,
  fetchurl,
  stdenv,
  runCommand,
  tailwindcss,
}:
let
  inherit (stdenv.hostPlatform) system;
  throwSystem = throw "tailwindcss has not been packaged for ${system} yet.";

  plat =
    {
      aarch64-darwin = "macos-arm64";
      aarch64-linux = "linux-arm64";
      armv7l-linux = "linux-armv7";
      x86_64-darwin = "macos-x64";
      x86_64-linux = "linux-x64";
    }
    .${system} or throwSystem;

  hash =
    {
      aarch64-darwin = "sha256-AXUcYBnBtL94fS4LHyIb7xvMAQzvVTE/wGkfO2o7Z28=";
      aarch64-linux = "sha256-HmdGu6bz0011UIiaGgCauQ7jeUpevOYO0QaIrRBoCoc=";
      armv7l-linux = "sha256-OLWmAuwp1/W+DUx4N9pgedg2mELT+hFMYiUJu06g35U=";
      x86_64-darwin = "sha256-IglipvNx/DFgX4lWmtZHMJy9g0cc2MKbg/I1pQHDnc4=";
      x86_64-linux = "sha256-M/JUtUyHVPFu++K+HeOMolGSYw3DbxZFladw1Lv02JM=";
    }
    .${system} or throwSystem;
in
stdenv.mkDerivation rec {
  pname = "tailwindcss";
  version = "3.4.16";

  src = fetchurl {
    url = "https://github.com/tailwindlabs/tailwindcss/releases/download/v${version}/tailwindcss-${plat}";
    inherit hash;
  };

  dontUnpack = true;
  dontConfigure = true;
  dontBuild = true;
  dontFixup = true;

  installPhase = ''
    mkdir -p $out/bin
    cp ${src} $out/bin/tailwindcss
    chmod 755 $out/bin/tailwindcss
  '';

  passthru.tests.helptext = runCommand "tailwindcss-test-helptext" { } ''
    ${tailwindcss}/bin/tailwindcss --help > $out
  '';
  passthru.updateScript = ./update.sh;

  meta = with lib; {
    description = "Command-line tool for the CSS framework with composable CSS classes, standalone CLI";
    homepage = "https://tailwindcss.com/blog/standalone-cli";
    license = licenses.mit;
    sourceProvenance = [ sourceTypes.binaryNativeCode ];
    maintainers = [ maintainers.adamcstephens ];
    mainProgram = "tailwindcss";
    platforms = platforms.darwin ++ platforms.linux;
  };
}
