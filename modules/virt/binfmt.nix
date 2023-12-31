{ config, pkgs, lib, ... }:
let
  inherit (lib) fakeHash mkOption types;
  inherit (types) attrsOf str submodule;

  cfg = config.boot.binfmt.qemuUserEmu;
in
{
  options.boot.binfmt.qemuUserEmu = mkOption {
    type = attrsOf (submodule {
      options = {
        version = mkOption {
          type = str;
        };
        hash = mkOption {
          type = str;
          default = fakeHash;
        };
      };
    });
    default = { };
  };

  config.boot.binfmt = {
    emulatedSystems = builtins.attrNames cfg;
    registrations = builtins.mapAttrs
      (name: { hash, version }:
        let
          arch = builtins.head (builtins.match "([^-]+)-.*" name);
          pname = "qemu-${arch}-static";
          drv = pkgs.stdenvNoCC.mkDerivation {
            inherit pname version;
            src = pkgs.fetchurl {
              url = "https://github.com/multiarch/qemu-user-static/releases/download/${version}/${pname}";
              inherit hash;
            };
            dontUnpack = true;
            installPhase = ''
              install -Dm755 "$src" "$out/bin/${pname}"
            '';
          };
        in
        {
          interpreter = "${drv}/bin/${pname}";
          fixBinary = true;
        })
      cfg;
  };
}
