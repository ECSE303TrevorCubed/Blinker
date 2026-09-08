{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    treefmt-nix.url = "github:numtide/treefmt-nix";
    uv2nix.url = "github:pyproject-nix/uv2nix";
    pybuild.url = "github:pyproject-nix/build-system-pkgs";
    pyproject.url = "github:pyproject-nix/pyproject.nix";
  };

  outputs =
    { self, ... }@inputs:
    inputs.flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import inputs.nixpkgs { inherit system; };
        treefmtconfig = inputs.treefmt-nix.lib.evalModule pkgs {
          projectRootFile = "flake.nix";
          programs = {
            alejandra.enable = true;
            toml-sort.enable = true;
            yamlfmt.enable = true;
            mdformat = {
              enable = true;
              plugins = ps: [
                ps.mdformat-gfm
              ];
              settings = {
                wrap = 88;
                end-of-line = "lf";
              };
            };
            clang-format.enable = true;
            shellcheck.enable = true;
            shfmt.enable = true;
            nixfmt.enable = true;
            typstyle.enable = true;
          };
          settings.formatter.shellcheck.excludes = [
            ".envrc"
          ];
        };
        python = pkgs.python314;
        workspace = inputs.uv2nix.lib.workspace.loadWorkspace {
          workspaceRoot = ./py;
        };
        overlay = workspace.mkPyprojectOverlay {
          sourcePreference = "wheel";
        };
        pyprojectOverrides = final: prev: {
          lgpio = prev.lgpio.overrideAttrs (old: {
            nativeBuildInputs = (old.nativeBuildInputs or [ ]) ++ [
              final.setuptools
              pkgs.swig
            ];
            buildInputs = (old.buildInputs or [ ]) ++ [
              pkgs.lgpio
            ];
          });
        };
        pythonBase = pkgs.callPackage inputs.pyproject.build.packages {
          inherit python;
        };
        pythonSet = pythonBase.overrideScope (
          pkgs.lib.composeManyExtensions [
            inputs.pybuild.overlays.wheel
            overlay
            pyprojectOverrides
          ]
        );
        venv = pythonSet.mkVirtualEnv "venv" workspace.deps.default;
        venvDev = pythonSet.mkVirtualEnv "venvDev" (workspace.deps.all or workspace.deps.default);
        inherit (pkgs.callPackages inputs.pyproject.build.util { }) mkApplication;
      in
      {
        formatter = treefmtconfig.config.build.wrapper;
        devShells.default = pkgs.mkShell {
          nativeBuildInputs = with pkgs; [
            clang-tools
            pkg-config
            gcc
          ];

          packages =
            with pkgs;
            [
              typst
              typstyle
              nil
              nixd
              uv
              swig
            ]
            ++ [
              wiringpi
              venvDev
            ]
            ++ pkgs.lib.optionals pkgs.stdenv.isLinux [ wiringpi ];

          env = {
            UV_NO_SYNC = "1";
            UV_PYTHON = pythonSet.python.interpreter;
            UV_PYTHON_DOWNLOADS = "never";
          };

          shellHook = ''
            PROJ_ROOT=$(git rev-parse --show-toplevel)/py
            export PYTHONPATH="$PROJ_ROOT:${venvDev}/lib/*/site-packages:$PYTHONPATH"
            export LD_LIBRARY_PATH="${pkgs.file}/lib:$LD_LIBRARY_PATH"
            ln -sfn ${venvDev} $PROJ_ROOT/.venv
          '';
        };
        packages =
          let
            blink_py = pkgs.callPackage ./nix/py.nix { inherit mkApplication pythonSet venv; };
            blink_c = pkgs.callPackage ./nix/c.nix { };
          in
          {
            default = blink_c;
            inherit blink_py;
            inherit blink_c;
          };
        checks = {
          formatting = treefmtconfig.config.build.check self;
        };
      }
    );
}
