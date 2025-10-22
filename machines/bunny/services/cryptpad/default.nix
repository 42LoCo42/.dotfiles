{ pkgs, lib, config, ... }:
let
  plugins = "${pkgs.cryptpad}/lib/node_modules/cryptpad/lib/plugins";

  cryptpad-sso = pkgs.stdenv.mkDerivation rec {
    pname = "cryptpad-sso";
    version = "0.4.0";

    src = pkgs.fetchFromGitHub {
      owner = "cryptpad";
      repo = "sso";
      tag = version;
      hash = "sha256-WkiWnRwXSvGJt0pMV5kAreqGlyj7aMO5RLHBZK4+CII=";
    };

    patches = [
      ./0001-get-config-location-from-environment.patch
    ];

    installPhase = "cp -r . $out";
  };
in
{
  topology.nodes.bunny-public.services.cryptpad = {
    name = "CryptPad";
    icon = "services.cryptpad";
    info = "Collaborative office suite";
    details.url.text = "https://pad.eleonora.gay";
  };

  rice.caddy.cfg = {
    "pad" = ''
      import default
      reverse_proxy cryptpad:8080
    '';

    "internal.pad" = ''
      import default
      reverse_proxy cryptpad:8080
    '';
  };

  virtualisation.pnoc.cryptpad = {
    cmd = [ (lib.getExe pkgs.cryptpad) ];

    environment = {
      CRYPTPAD_CONFIG = "${./config.js}";
      CRYPTPAD_SSO_CONFIG = "${./sso.js}";

      DOMAIN = config.rice.domain;
    };

    environmentFiles = [ (config.aquaris.secret "@machine/cryptpad") ];

    extraOptions = [ "--tmpfs=${plugins}" ];

    volumes = [
      "cryptpad:/data"
      "${cryptpad-sso}:${plugins}/sso:ro"
    ];

    workdir = "/data";
  };
}
