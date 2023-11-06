{ stdenv, fetchFromGitHub, cmake, meson, pkg-config, dbus, ninja, glib, libtool
}:
stdenv.mkDerivation rec {
  name = "iio-hyprland-${version}";
  version = "1.0";

  # For https://github.com/myuser/myexample
  src = fetchFromGitHub {
    owner = "JeanSchoeller";
    repo = "iio-hyprland";
    rev =
      "f31ee4109379ad7c3a82b1a0aef982769e482faf"; # If there is a release like v1.0, otherwise put the commit directly
    sha256 =
      "sha256-P+m2OIVS8QSQmeVYVIgt2A6Q/I3zZX3bK9UNLyQtNOg="; # <-- dummy hash: after the first compilation this line will give an error and the correct hash. Replace lib.fakeSha256 with "givenhash". Or use nix-prefetch-git
  };

  nativeBuildInputs = [ meson cmake pkg-config dbus.dev ninja libtool ];
  buildInputs = [ glib ];

  buildPhase = ''
    cd ../
    make
    cd build
  '';

  installPhase = ''
    mkdir -p $out/bin
    cp iio-hyprland $out/bin
  '';
}
