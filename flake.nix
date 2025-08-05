{
  description = "Flake for testing G-ADOPT";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    self.submodules = true;
    gadopt-repo = {
      url = "path:./g-adopt";
      flake = false;
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      gadopt-repo,
      ...
    }:
    let
      supportedSystems = [
        "x86_64-linux"
        "aarch64-darwin"
      ];
      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;
      nixpkgsFor = forAllSystems (system: import nixpkgs { inherit system; });
    in
    {
      packages = forAllSystems (
        system:
        let
          pkgs = nixpkgsFor.${system};
          pypkgs = pkgs.python3Packages;

          trilinos = pkgs.callPackage ./pkgs/trilinos.nix { };

          assess = pkgs.python3.pkgs.callPackage ./pkgs/assess.nix { };
          flib = pkgs.python3.pkgs.callPackage ./pkgs/flib.nix { };
          pygplates = pkgs.libsForQt5.callPackage ./pkgs/pygplates.nix { };
          pyrol = pkgs.python3.pkgs.callPackage ./pkgs/pyrol.nix {
            trilinos = trilinos;
          };

          vtk_9_4 = pypkgs.toPythonModule (
            (pkgs.libsForQt5.callPackage
              (import "${nixpkgs}/pkgs/development/libraries/vtk/generic.nix" {
                version = "9.4.2";
                sourceSha256 = "sha256-NsmODalrsSow/lNwgJeqlJLntm1cOzZuHI3CUeKFagI=";
              })
              {
                pythonSupport = true;
                # must build with LLVM 17 to avoid errors in the JSON third party
                # lib trying to instantiate std::char_traits<unsigned char>
                stdenv = pkgs.llvmPackages_17.stdenv;
              }
            ).overrideAttrs (old: {
              cmakeFlags = old.cmakeFlags ++ [
                # VTK is going to force C++11 if we don't define this, which breaks
                # Boost.Math
	        (pkgs.lib.cmakeBool "VTK_IGNORE_CMAKE_CXX11_CHECKS" true)
                # I guess we're using a newer version of NetCDF, so __FillValue is
                # behind a macro now
	        (pkgs.lib.cmakeFeature "CMAKE_CXX_FLAGS" "-DNETCDF_ENABLE_LEGACY_MACROS")
	        (pkgs.lib.cmakeFeature "CMAKE_C_FLAGS" "-DNETCDF_ENABLE_LEGACY_MACROS")
	        (pkgs.lib.cmakeFeature "CMAKE_CXX_STANDARD" "17")
	      ];
            })
          );
        in
        {
          gadopt = pypkgs.buildPythonPackage {
            pname = "gadopt";
            version = "0.1.0.dev0";
            src = gadopt-repo;
            pyproject = true;

            build-system = [
              pypkgs.setuptools
              pypkgs.setuptools-scm
            ];

            dontWrapQtApps = true;

            dependencies = [
              pypkgs.firedrake

              assess
              flib
              pygplates
              pyrol

              pkgs.gmsh

              pypkgs.gmsh
              pypkgs.imageio
              pypkgs.matplotlib
              pypkgs.openpyxl
              pypkgs.pandas
              pypkgs.pytest
              pypkgs.shapely
              pypkgs.siphash24
              vtk_9_4
            ];
          };
          tsp = pkgs.stdenv.mkDerivation rec {
            pname = "tsp";
            version = "1.3.0";

            src = pkgs.fetchFromGitHub {
              owner = "dsroberts";
              repo = "tsp_for_hpc";
              rev = "v${version}";
              sha256 = "sha256-E9q/xzQuDvB+a549YJZxPmbT21v5ldQXwv/qa0hzhdg=";
            };

            nativeBuildInputs = [ pkgs.cmake ];
            buildInputs = [
              pkgs.hwloc
              pkgs.sqlite
            ];

            installPhase = ''
              mkdir -p $out/bin
              install -Dm755 tsp-hpc $out/bin/tsp
            '';

            meta = with pkgs.lib; {
              description = "Serverless task spooler";
              homepage = "https://github.com/dsroberts/tsp_for_hpc";
              license = licenses.asl20;
            };
          };
        }
      );
      devShell = forAllSystems (
        system:
        let
          pkgs = nixpkgsFor.${system};
        in
        pkgs.mkShell {
          packages = [
            self.packages.${system}.gadopt
            self.packages.${system}.tsp
          ];
          shellHook = ''
            export OMP_NUM_THREADS=1
          '';
        }
      );
    };
}
