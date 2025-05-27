{
  stdenv,
  lib,
  fetchFromGitHub,
  cmake,
  blas,
  boost,
  lapack,
}:

stdenv.mkDerivation rec {
  pname = "trilinos";
  version = "16.1.0";

  src = fetchFromGitHub {
    owner = "angus-g";
    repo = "trilinos";
    tag = "pyrol-${version}";
    sha256 = "sha256-mvP1LzUOOVqGHcOAPpyiCHka1G5oEikqBJk/HIhk2FI=";
  };

  nativeBuildInputs = [ cmake ];
  propagatedBuildInputs = [
    blas
    boost
    lapack
  ];

  cmakeFlags = [
    (lib.cmakeBool "BUILD_SHARED_LIBS" true)
    (lib.cmakeBool "Trilinos_ENABLE_Fortran" false)
    (lib.cmakeBool "TPL_ENABLE_MPI" false)
    (lib.cmakeBool "Trilinos_ENABLE_ALL_OPTIONAL_PACKAGES" false)
    (lib.cmakeBool "Trilinos_ENABLE_ROL" true)
    (lib.cmakeFeature "ROL_Ptr" "std::shared_ptr")
    (lib.cmakeBool "ROL_ENABLE_EXAMPLES" false)
    (lib.cmakeBool "ROL_ENABLE_Sacado" false)
    (lib.cmakeBool "TPL_ENABLE_BLAS" true)
    (lib.cmakeBool "TPL_ENABLE_LAPACK" true)
  ];
  preConfigure = ''
    cmakeFlagsArray+=("-DCMAKE_CXX_FLAGS=-O3 -fPIC")
  '';

  meta = with lib; {
    description = "Engineering and scientific problems algorithms";
    homepage = "https://trilinos.org";
    license = licenses.bsd3;
  };
}
