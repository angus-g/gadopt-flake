{
  lib,
  buildPythonPackage,
  pkgs,
  trilinos,
}:

buildPythonPackage rec {
  pname = "pyrol";
  version = "0.5.4";
  pyproject = true;

  src = pkgs.fetchFromGitHub {
    owner = "angus-g";
    repo = "pyrol";
    rev = "external-rol";
    sha256 = "sha256-mhxzU5dQTrXRnMdpa4gwLvpw3QCxKuJ5Xd0ah4mo0eY=";
  };

  build-system = [
    pkgs.python3Packages.setuptools
    pkgs.python3Packages.setuptools-scm
    pkgs.cmake pkgs.git
    pkgs.python3Packages.pybind11
  ];
  dontUseCmakeConfigure = true;

  buildInputs = [
    trilinos
    pkgs.cereal
    pkgs.fmt
  ];

  doCheck = false;

  meta = with lib; {
    description = "Python interface to ROL 2.0";
    homepage = "https://github.com/angus-g/pyrol";
    license = licenses.lgpl3;
  };
}
