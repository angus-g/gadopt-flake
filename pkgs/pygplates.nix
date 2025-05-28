{
  lib,
  pkgs,
  qwt,
  darwin,
  wrapQtAppsHook,
}:

let
  boost = pkgs.boost.override {
    enablePython = true;
    python = pkgs.python3;
  };
in
pkgs.python3.pkgs.buildPythonPackage rec {
  pname = "pygplates";
  version = "1.0.0";
  pyproject = true;

  src = pkgs.fetchPypi {
    inherit pname version;
    hash = "sha256-YgoTDrHNwEKGjS4SUVlrLttuHOFZb6vh3jiWIZBJkyA=";
  };

  dontWrapQtApps = true;

  build-system = [
    pkgs.cmake pkgs.ninja
    pkgs.python3Packages.scikit-build-core
    wrapQtAppsHook
  ];
  dontUseCmakeConfigure = true;

  configurePhase = ''
    # will eat all the CPUs otherwise
    export CMAKE_BUILD_PARALLEL_LEVEL=$NIX_BUILD_CORES
  '';

  pypaBuildFlags = [
    "--config=cmake.define.GPLATES_INSTALL_STANDALONE_SHARED_LIBRARY_DEPENDENCIES=FALSE"
  ];

  postPatch = ''
    substituteInPlace pyproject.toml \
      --replace-fail 'scikit-build-core>=0.10,<0.11' 'scikit-build-core>=0.10'
  '';

  dependencies = [
    pkgs.python3Packages.numpy
    pkgs.glew
    pkgs.zlib
    pkgs.cgal pkgs.gdal pkgs.proj
    pkgs.gmp pkgs.mpfr
    boost
    pkgs.qt5.qtxmlpatterns qwt
  ];

  doCheck = false;

  meta = with lib; {
    description = "A library for accessing GPlates functionality";
    homepage = "https://www.gplates.org/";
    license = licenses.gpl2;
  };
}
