{ lib
, stdenv
, fetchFromGitHub
, cmake
, meson
, ninja
, pkg-config
, fcitx5
, libgovarnam
}:

stdenv.mkDerivation rec {
  pname = "varnam-fcitx5";
  version = "unstable-2024-05-19";

  src = fetchFromGitHub {
    owner = "varnamproject";
    repo = "varnam-fcitx5";
    rev = "e6366e4755e21dd3a162f38f21df4e5c37c64ae2";
    hash = "sha256-E9mdA6j9VFSMQwkrfGLcHUFrF0w7zWjgt+2h4MEqkPQ=";
  };

  patches = [
    ./remove_old_meson_options_file.patch
  ];

  depsBuildBuild = [ pkg-config ];
  nativeBuildInputs = [
    cmake
    pkg-config
    meson
    ninja
    fcitx5
    libgovarnam
  ];
  buildInputs = [ fcitx5 libgovarnam ];

  configurePhase = ''
    runHook preConfigure

    meson setup builddir

    runHook postConfigure
  '';

  buildPhase = ''
    runHook preBuild

    cd builddir
    meson compile

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/lib/fcitx5
    cp src/varnamfcitx.so $out/lib/fcitx5

    mkdir -p $out/share/fcitx5/{inputmethod,addon}
    cp ${src}/src/varnamfcitx.conf $out/share/fcitx5/inputmethod
    cp ${src}/src/varnamfcitx-addon.conf $out/share/fcitx5/addon/varnamfcitx.conf
    
    mkdir -p $out/share/icons/hicolor/48x48/apps
    cp ${src}/icons/*.png $out/share/icons/hicolor/48x48/apps/

    runHook postInstall
  '';

  mesonBuildType = "native";

  meta = {
    description = "Fcitx5 wrapper for Varnam Input Method Engine";
    homepage = "https://github.com/varnamproject/varnam-fcitx5";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ adtya ];
    mainProgram = "varnam-fcitx5";
    platforms = lib.platforms.linux;
  };
}
