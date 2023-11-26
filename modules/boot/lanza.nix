{ self, pkgs, lib, ... }: {
  imports = [
    ./default.nix
  ];

  boot = {
    loader.systemd-boot.enable = lib.mkForce false;

    lanzaboote = {
      enable = true;
      pkiBundle = "/etc/secureboot";
      package = lib.mkForce (pkgs.writeShellScriptBin "lzbt" ''
        [ -e /etc/secureboot/keys ] || ${pkgs.sbctl}/bin/sbctl create-keys
        exec ${self.inputs.lanzaboote.packages.${pkgs.system}.lzbt}/bin/lzbt "$@"
      '');
    };
  };
}
