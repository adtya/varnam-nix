{ lib
, buildGoModule
, fetchzip
, pkg-config
, libgovarnam
, makeWrapper
, selected_schemes ? [ ]
}:

let
  schemeShas = import ./schemes.nix;
  knownSchemes = builtins.attrNames schemeShas;
  selectedSchemes =
    if (selected_schemes == [ ])
    then knownSchemes
    else
      let
        unknown = lib.subtractLists knownSchemes selected_schemes;
      in
      if (unknown != [ ])
      then throw "Unknown scheme(s): ${lib.concatStringsSep " " unknown}"
      else selected_schemes;
  schemeSrcs = lib.lists.forEach selectedSchemes (
    name: (fetchzip {
      url = schemeShas.${name}.url;
      sha256 = schemeShas.${name}.sha;
    })
  );
in
buildGoModule rec {
  pname = "varnam-cli";
  version = libgovarnam.version;

  src = libgovarnam.src;

  vendorHash = "sha256-a7m2THvdi17muJI6p6OVX9cBMcmocYwju29beG2H8CY=";

  CGO_ENABLED = 1;

  nativeBuildInputs = [ pkg-config libgovarnam makeWrapper ];
  buildInputs = [ pkg-config libgovarnam ];

  ldflags = [
    "-w"
    "-s"
    "-X 'github.com/varnamproject/govarnam/govarnam.BuildString=${version} (\#0000000 1970-01-01T00:00:00+0000)'"
    "-X 'github.com/varnamproject/govarnam/govarnam.VersionString=${version}'"
  ];

  subPackages = [
    "cli"
  ];

  postInstall = ''
    mkdir -p $out/share/varnam/schemes
    cp ${toString (lib.lists.forEach schemeSrcs (scheme: "${scheme}/*.vst"))} $out/share/varnam/schemes/

    mv $out/bin/cli $out/bin/.varnamcli
    makeWrapper $out/bin/.varnamcli $out/bin/varnamcli --set VARNAM_VST_DIR $out/share/varnam/schemes
  '';

  meta = {
    description = "Easily type Indic languages on computer and mobile. GoVarnam is a cross-platform transliteration library. Manglish -> Malayalam, Thanglish -> Tamil, Hinglish -> Hindi plus another 10 languages. GoVarnam is a near-Go port of libvarnam";
    homepage = "https://github.com/varnamproject/govarnam";
    license = lib.licenses.agpl3Only;
    maintainers = with lib.maintainers; [ adtya ];
    mainProgram = "varnamcli";
  };
}
