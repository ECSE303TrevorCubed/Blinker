{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    { nixpkgs, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs { inherit system; };
      in
      {
        devShells.default = pkgs.mkShell {
          nativeBuildInputs = with pkgs; [
            clang-tools
            pkg-config
            gcc
          ];

          packages = with pkgs; [
            python3
            typst
            typstyle
            nil
            nixd
          ] ++ [
            wiringpi
          ] ++ pkgs.lib.optionals pkgs.stdenv.isLinux [ wiringpi ];
        };
        packages = let
          blink_c = pkgs.callPackage ./nix/c.nix {};
        in {
          default = blink_c;
          inherit blink_c;
        };
      }
    );
}
