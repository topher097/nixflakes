{ pkgs ? import <nixpkgs> {} }:

pkgs.stdenv.mkDerivation {
  name = "filezilla-pro";
  src = ./FileZilla_Pro_3.69.0_x86_64-linux-gnu.tar.xz;

  nativeBuildInputs = [ pkgs.autoPatchelfHook ];

  # These packages are mostly from the nixpkgs filezilla derivation
  buildInputs = with pkgs; [
    wxGTK32
    gtk3
    glib
    libidn2
    libexif
    libfilezilla
    # libfilezilla-common
    libfm
    libfm-extra
    libnghttp2
    libpsl
    libssh2
    libxml2
    libxslt
    nettle
    pcre
    pugixml
    sqlite
    zlib
    libGL
    mesa
    alsa-lib
    pulseaudio
    dbus
    expat
    fontconfig
    freetype
    xorg.libX11
    xorg.libXcursor
    xorg.libXrandr
    libxcrypt-legacy
  ];

  dontBuild = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out
    cp -r * $out

    runHook postInstall
  '';

  meta = with pkgs.lib; {
    description = "FileZilla Pro";
    license = licenses.unfree;
    platforms = [ "x86_64-linux" ];
  };
}