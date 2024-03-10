{ lib
, buildPythonPackage
, fetchPypi
}:

buildPythonPackage rec {
  pname = "types-decorator";
  version = "5.1.8.20240310";
  format = "setuptools";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-UuMWsDeDiGqKKr3CKPcHFoC6ZYlFRc0ghevjz4hoSg4=";
  };

  # Modules doesn't have tests
  doCheck = false;

  pythonImportsCheck = [
    "decorator-stubs"
  ];

  meta = with lib; {
    description = "Typing stubs for decorator";
    homepage = "https://github.com/python/typeshed";
    license = licenses.asl20;
    maintainers = with maintainers; [ fab ];
  };
}
