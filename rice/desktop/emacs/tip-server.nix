pkgs:
let
  inherit (pkgs.lib) getExe;

  rust = pkgs.rustPlatform;
  python = pkgs.python3;
  inherit (python.pkgs) buildPythonPackage fetchPypi;

  oslash = buildPythonPackage rec {
    pname = "OSlash";
    version = "0.6.3";

    src = fetchPypi {
      inherit pname version;
      hash = "sha256-horrWKZW8u07c9ndar44eyC3T8lBPT6GU7YVsVv3KPM=";
    };

    patches = [
      ./patches/oslash/0001-SafeConfigParser-has-been-removed.patch
      ./patches/oslash/0002-pytest-runner-has-been-removed.patch
    ];

    pyproject = true;

    build-system = with python.pkgs; [
      setuptools
    ];

    dependencies = with python.pkgs; [
      typing-extensions
    ];
  };

  jsonrpcserver = buildPythonPackage rec {
    pname = "jsonrpcserver";
    version = "5.0.9";

    src = fetchPypi {
      inherit pname version;
      hash = "sha256-px+yz6GFQcgJNfYJh/knVdlNdBQSSMdDiEe5bu5cRII=";
    };

    pyproject = true;

    build-system = with python.pkgs; [
      setuptools
    ];

    dependencies = with python.pkgs; [
      jsonschema
      oslash
    ];
  };

  typst = buildPythonPackage rec {
    pname = "typst";
    version = "0.12.3";

    src = fetchPypi {
      inherit pname version;
      hash = "sha256-94fuHeYCqTCuLihA8vlYcNWi5ysyQBHe3a0t6xp6dGI=";
    };

    cargoDeps = rust.fetchCargoTarball {
      inherit pname version src;
      hash = "sha256-H7lKoSDSx0cGH+VsIX90KaiWJw1h/BokNdKzxmvm6XQ=";
    };

    nativeBuildInputs = with rust; with pkgs; [
      cargoSetupHook
      maturinBuildHook

      pkg-config
    ];

    buildInputs = with pkgs; [
      openssl
    ];

    OPENSSL_NO_VENDOR = "1";

    pyproject = true;
  };

  python' = python.withPackages (_: [
    jsonrpcserver
    typst
  ]);

  tip-server = pkgs.stdenv.mkDerivation rec {
    pname = "tip-server";
    version = "2024-05-18";

    src = pkgs.fetchFromSourcehut {
      owner = "~mafty";
      repo = "tip-server-py";
      rev = "972cbc204950909c14c6387e7585073061765fe7";
      hash = "sha256-vm3/21elubw2GfVOmrF7OP4B6LSSyeotuD5DTZEwDNc=";
    };

    patches = [
      ./patches/tip-server/0001-use-temporary-file-instead-of-hello.typ.patch
    ];

    installPhase = ''
      install -Dm755 <({
        echo "#!${getExe python'}"
        cat main.py
      }) $out/bin/${pname}
    '';
  };
in
tip-server
