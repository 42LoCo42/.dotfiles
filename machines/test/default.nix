{ self, nixpkgs, my-utils }@args: nixpkgs.lib.nixosSystem rec {
  system = "x86_64-linux";
  specialArgs = args // my-utils system;
  modules = [
    ./hardware.nix
    ./feengold.nix
    ./zfs-autokey.nix

    self.inputs.disko.nixosModules.disko
    self.inputs.home-manager.nixosModules.home-manager
    self.inputs.lanzaboote.nixosModules.lanzaboote

    "${self}/modules/base/all.nix"
    "${self}/modules/boot/lanza.nix"
    "${self}/modules/boot/zfs.nix"
    "${self}/modules/home/terminal.nix"
    "${self}/modules/networking/default.nix"

    ({ pkgs, lib, ... }: {
      _module.args.und = {
        host = "192.168.122.130";
        user = "leonsch";
        preUser = "root";
        kexec = "192.168.122.1:8000/nixos-kexec-installer-x86_64-linux.tar.gz";
      };

      machine-id = "28b614da10fbda25dabb87d7653faf3a";

      networking = {
        hostName = "test";
        networkmanager.enable = lib.mkForce false;
      };

      age.identityPaths = lib.mkForce [ "/persist/age.key" ];

      security.pam.services.login.text = lib.mkDefault (lib.mkBefore ''
        auth    optional pam_exec.so expose_authtok ${self}/zfs-pam rpool/nixos/home
        session optional pam_exec.so ${pkgs.systemd}/bin/systemd-run -E PATH=/run/current-system/sw/bin -E PAM_USER -E PAM_TYPE ${self}/zfs-pam rpool/nixos/home
      '');

      environment.feengold = {
        binds = [
          "/etc/secureboot"
          "/var/db/sudo"
          "/var/log"
        ];

        links = [
          "/etc/ssh/ssh_host_ed25519_key"
          "/etc/ssh/ssh_host_ed25519_key.pub"
        ];

        users.default = [
          ".cache/zsh"
          ".local/share/zoxide"
        ];
      };
    })
  ];
}
