{ pkgs, lib, my-utils, ... }: {
  imports = [
    ./default.nix
    my-utils.lanza.nixosModules.lanzaboote
  ];

  boot = {
    loader.systemd-boot.enable = lib.mkForce false;

    lanzaboote = {
      enable = true;
      pkiBundle = "/etc/secureboot";
      package = lib.mkForce (pkgs.writeShellScriptBin "lzbt" ''
        [ -e /etc/secureboot/keys ] || ${pkgs.sbctl}/bin/sbctl create-keys
        exec ${my-utils.lanza.packages.${pkgs.system}.lzbt}/bin/lzbt "$@"
      '');
    };
  };
}
