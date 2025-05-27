{
  lib,
  buildPythonPackage,
  pkgs,
}:

buildPythonPackage rec {
  pname = "assess";
  version = "1.0";

  src = pkgs.fetchPypi {
    inherit pname version;
    hash = "sha256-aeltR0fJ5KT3uAsS9U5cKfC7YVxZJIi9gTsX/zHcO6o=";
  };

  doCheck = false;
    meta = with lib; {
    description = "Analytical Solutions for the Stokes Equation in Spherical Shells";
    homepage = "https://github.com/stephankramer/assess";
    license = licenses.gpl3;
  };
}
