{ stdenv, pkg-config, wiringpi, ... }:
stdenv.mkDerivation {
  pname = "blinker_c";
  version = "0.0.1";
  src = ../src;
  nativeBuildInputs = [
    pkg-config
  ];
  buildInputs = [ wiringpi ];
}
