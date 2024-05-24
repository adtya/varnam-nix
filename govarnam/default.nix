{ lib
, buildGoModule
, fetchFromGitHub
, pkg-config
, libgovarnam
}:

buildGoModule rec {
  pname = "varnam-cli";
  version = "1.9.1";

  src = fetchFromGitHub {
    owner = "varnamproject";
    repo = "govarnam";
    rev = "v${version}";
    hash = "sha256-7SYdeOMgc8VBx0rsu6tWGND9mq0Td1VeGmZrpfsWsVE=";
    fetchSubmodules = true;
  };

  vendorHash = "sha256-a7m2THvdi17muJI6p6OVX9cBMcmocYwju29beG2H8CY=";

  CGO_ENABLED = 1;

  nativeBuildInputs = [ pkg-config libgovarnam ];


  ldflags = [
    "-w"
    "-s"
    "-X 'github.com/varnamproject/govarnam/govarnam.BuildString=${version} (\#0000000 1970-01-01T00:00:00+0000)'"
    "-X 'github.com/varnamproject/govarnam/govarnam.VersionString=${version}'"
  ];


  subPackages = [
    "cli"
  ];

  meta = {
    description = "Easily type Indic languages on computer and mobile. GoVarnam is a cross-platform transliteration library. Manglish -> Malayalam, Thanglish -> Tamil, Hinglish -> Hindi plus another 10 languages. GoVarnam is a near-Go port of libvarnam";
    homepage = "https://github.com/varnamproject/govarnam";
    license = lib.licenses.agpl3Only;
    maintainers = with lib.maintainers; [ adtya ];

  };
}
