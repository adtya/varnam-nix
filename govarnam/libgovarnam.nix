{ lib
, buildGoModule
, fetchFromGitHub
}:

buildGoModule rec {
  pname = "libgovarnam";
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

  buildPhase = ''
    runHook preInstall

    go build -tags "fts5" -buildmode=c-shared -ldflags \
    "-s -w -X 'github.com/varnamproject/govarnam/govarnam.BuildString=${version} (\#0000000 1970-01-01T00:00:00+0000)' \
    -X 'github.com/varnamproject/govarnam/govarnam.VersionString=${version}' \
    -extldflags "-Wl,-soname,${pname}.so.1,--version-script,${src}/govarnam.syms"" -o ${pname}.so .

    runHook postInstall
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/lib
    cp ${pname}.so $out/lib/${pname}.so.${version}
    ln -s $out/lib/${pname}.so.${version} $out/lib/${pname}.so
    ln -s $out/lib/${pname}.so.${version} $out/lib/${pname}.so.1

    mkdir -p $out/lib/pkgconfig
    cp govarnam.pc.in $out/lib/pkgconfig/govarnam.pc
    sed -i "s#@INSTALL_PREFIX@#$out#g" $out/lib/pkgconfig/govarnam.pc
    sed -i "s#@VERSION@#${version}#g" $out/lib/pkgconfig/govarnam.pc

    mkdir -p $out/include/${pname}
    cp *.h $out/include/${pname}/

    runHook postInstall
  '';


  meta = {
    description = "Easily type Indic languages on computer and mobile. GoVarnam is a cross-platform transliteration library. Manglish -> Malayalam, Thanglish -> Tamil, Hinglish -> Hindi plus another 10 languages. GoVarnam is a near-Go port of libvarnam";
    homepage = "https://github.com/varnamproject/govarnam";
    license = lib.licenses.agpl3Only;
    maintainers = with lib.maintainers; [ adtya ];
    pkgConfigModules = [ pname ];

  };
}
