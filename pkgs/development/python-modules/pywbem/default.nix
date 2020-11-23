{ lib, buildPythonPackage, fetchPypi, libxml2
, m2crypto, ply, pyyaml, six, pbr, pythonOlder, isPy37
, httpretty, lxml, mock, pytest, requests, decorator, unittest2
}:

buildPythonPackage rec {
  pname = "pywbem";
  version = "1.0.3";

  # Support added in master https://github.com/pywbem/pywbem/commit/b2f2f1a151a30355bbc6652dca69a7b30bfe941e awaiting release
  disabled = isPy37;

  src = fetchPypi {
    inherit pname version;
    sha256 = "a6c53d9426326e0e722a5b1af3a1d55810259cb3afa92ca5e4029a6d533cab37";
  };

  propagatedBuildInputs = [
    mock
    pbr
    ply
    pyyaml
    six
  ] ++ lib.optionals (pythonOlder "3.0") [ m2crypto ];

  checkInputs = [
    decorator
    httpretty
    libxml2
    lxml
    pytest
    requests
    unittest2
  ];

  postPatch = ''
    # Uses deprecated library yamlordereddictloader
    rm testsuite/test_client.py

    # Wants `wbemcli` in PATH
    rm testsuite/test_wbemcli.py

    # Disables tests that use testfixtures which is currently broken by nonbuilding zope_component
    rm testsuite/{test_logging,test_recorder,test_wbemconnection_mock}.*
  '';

  checkPhase = ''
    pytest testsuite/
  '';

  meta = with lib; {
    description = "Support for the WBEM standard for systems management";
    homepage = "https://pywbem.github.io";
    license = licenses.lgpl21Plus;
    maintainers = with maintainers; [ peterhoeg ];
  };
}
