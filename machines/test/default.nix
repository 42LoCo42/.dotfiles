{ self, nixpkgs }@args: nixpkgs.lib.nixosSystem {
  system = "x86_64-linux";
  specialArgs = args;
  modules = [
    ./disk.nix
    ./hardware.nix

    self.inputs.disko.nixosModules.disko
    self.inputs.home-manager.nixosModules.home-manager
    self.inputs.impermanence.nixosModules.impermanence
    # self.inputs.lanzaboote.nixosModules.lanzaboote

    "${self}/modules/base/all.nix"
    # "${self}/modules/boot/lanza.nix"
    "${self}/modules/boot/zfs.nix"
    "${self}/modules/home/terminal.nix"
    "${self}/modules/networking/default.nix"

    ({ pkgs, lib, ... }: {
      _module.args.und = {
        host = "192.168.122.92";
        user = "leonsch";
        kexec = "192.168.122.1:8000/nixos-kexec-installer-x86_64-linux.tar.gz";
      };

      boot.initrd = {
        kernelModules = [ "tpm_crb" ];

        systemd = {
          contents."/jwt".source = ./jwt.secret;
          initrdBin = with pkgs; [
            clevis
            jose
            tpm2-tools
          ];

          services = {
            # zfs-import-rpool = {
            #   script = lib.mkForce ''
            #     zpool import -N rpool
            #     clevis decrypt < /jwt | zfs load-key rpool/nixos
            #   '';
            # };
          };
        };
      };

      networking = {
        hostName = "test";
        hostId = "a5d4deab";

        networkmanager.enable = lib.mkForce false;
      };

      security.pam.zfs = {
        enable = true;
        homes = "rpool/nixos/users";
      };

      fileSystems."/persist".neededForBoot = true;
      environment.persistence."/persist" = {
        directories = [
          "/etc/secureboot"
          "/var/log/"
        ];
        files = [
          "/etc/machine-id"
          "/etc/ssh/ssh_host_ed25519_key"
          "/etc/ssh/ssh_host_ed25519_key.pub"
        ];

        users.leonsch = {
          files = [
            ".bash_history"
          ];
        };
      };

      virtualisation.docker = {
        enable = true;
        storageDriver = "zfs";
      };
    })
  ];
}
