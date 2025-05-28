{
  lib,
  buildPythonPackage,
  pkgs,
  python,
}:

buildPythonPackage rec {
  pname = "flib";
  version = "1.2.0";
  format = "other";

  src = pkgs.fetchFromGitHub {
    owner = "seantrim";
    repo = "exact-thermochem-solution";
    rev = "v${version}";
    sha256 = "sha256-Kj9QY2WmTsKIoA+Zdh/16u66tiXqedaB4zzdf/rhXkE=";
  };
  sourceRoot = "${src.name}/Python";

  build-system = [
    pkgs.meson pkgs.ninja
    pkgs.python3Packages.numpy
  ];
  nativeBuildInputs = [ pkgs.gfortran ];
  dependencies = [ pkgs.python3Packages.numpy ];

  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    mkdir -p $out/${python.sitePackages}
    rm *.so
    CFLAGS=-Wno-error=incompatible-pointer-types f2py -c --fcompiler=gfortran --f90flags=-flto --opt=-O3 -m flib ../Fortran/*.f90
    cp *.so $out/${python.sitePackages}
  '';

  meta = with lib; {
    description = "Exact solution for 2D thermochemical mantle convection models";
    license = licenses.gpl3;
  };
}
