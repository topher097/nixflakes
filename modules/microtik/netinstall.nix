{ 
    stdenv,
    lib,
    fetchzip
}:
stdenv.mkDerivation rec {
  pname = "netisntall";
  version = "7.18.2";

  src = fetchzip {
    url = "https://download.mikrotik.com/routeros/${version}/netinstall-${version}.tar.gz";
    sha256 = "f90a315921c3b7954c14b4bb7aec2b8a3f1f1ee751c355cee2e2e5de89c95f37";
  };


  buildPhase = "";
  installPhase = ''
    mkdir -p $out
    mv public $out
  '';
}