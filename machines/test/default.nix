{ self, nixpkgs }@args: nixpkgs.lib.nixosSystem {
  system = "x86_64-linux";
  specialArgs = args;
  modules = [
    ./hardware.nix
    ./feengold.nix

    self.inputs.disko.nixosModules.disko
    self.inputs.home-manager.nixosModules.home-manager
    self.inputs.lanzaboote.nixosModules.lanzaboote

    "${self}/modules/base/all.nix"
    "${self}/modules/boot/zfs.nix"
    "${self}/modules/home/terminal.nix"
    "${self}/modules/networking/default.nix"

    ({ pkgs, lib, ... }: {
      _module.args.und = {
        host = "192.168.122.92";
        user = "leonsch";
        preUser = "root";
        kexec = "192.168.122.1:8000/nixos-kexec-installer-x86_64-linux.tar.gz";
      };

      networking = {
        hostName = "test";
        networkmanager.enable = lib.mkForce false;
      };

      security.pam.services.login.text = lib.mkDefault (lib.mkBefore ''
        auth    optional pam_exec.so expose_authtok ${self}/zfs-pam rpool/nixos/home
        session optional pam_exec.so ${pkgs.systemd}/bin/systemd-run -E PATH=/run/current-system/sw/bin -E PAM_USER -E PAM_TYPE ${self}/zfs-pam rpool/nixos/home
      '');

      # this fixes occasional "failures" of zfs-mount
      systemd.services."zfs-mount".serviceConfig.Restart = "on-failure";

      environment.feengold = {
        # persistentLocation = "/persist"; # default

        directories = [
          { path = "/etc/secureboot"; neededForBoot = true; }
          { path = "/var/db/sudo"; mode = "0711"; }
          "/var/log"
        ];

        files = [
          "/etc/ssh/ssh_host_ed25519_key"
          "/etc/ssh/ssh_host_ed25519_key.pub"
        ];

        users.default = {
          links = [
            ".bash_history"
            ".local/share/zoxide/db.zo"
          ];
        };
      };
    })

    ({ pkgs, lib, config, ... }:
      let
        machine-id = "28b614da10fbda25dabb87d7653faf3a";
        initial = pkgs.writeText "initial-password" "feengold";

        import-lanza =
          if true # builtins.pathExists "/etc/secureboot/GUID"
          then [ "${self}/modules/boot/lanza.nix" ]
          else [ ];

        # jwt-path = "/persist/jwt";
        # jwt-exists = false; # builtins.pathExists jwt-path;

        # contents = if jwt-exists then { "/jwt".source = jwt-path; } else { };

        # initrdBin =
        #   if jwt-exists then with pkgs; [
        #     clevis
        #     jose
        #     tpm2-tools
        #   ] else [ ];

        # services =
        #   if jwt-exists then {
        #     zfs-import-rpool = {
        #       script = lib.mkForce ''
        #         zpool import -N rpool
        #         clevis decrypt < /jwt | zfs load-key rpool/nixos
        #       '';
        #     };
        #   } else { };

        # storePaths = if jwt-exists then [ ] else [ initial ];
      in
      {
        imports = [ (import ./disk.nix { inherit initial; }) ] ++ import-lanza;

        boot.initrd = {
          kernelModules = [ "tpm_crb" ];
          systemd = {
            # inherit contents initrdBin services storePaths;
            storePaths = [ initial ];
            # services.feengold-init = {
            #   description = "Feengold initial testing environment";
            #   # before = [ "local-fs.target" ];
            #   wantedBy = [ "sysinit.target" ];
            #   after = [ "sysroot-etc-secureboot.mount" ];
            #   unitConfig.DefaultDependencies = false;
            #   script = ''
            #     exec >& /sysroot/persist/feengold.log
            #     set -x
            #     mount
            #     ls /sysroot/etc/secureboot
            #     systemctl list-units
            #   '';
            # };
          };
        };

        system.activationScripts.feengold =
          let
            name = "feengold-activation";
            program = pkgs.writeShellApplication {
              inherit name;
              runtimeInputs = with pkgs; [
                clevis
                e2fsprogs
                mokutil
                sbctl
              ];
              text = ''
                if [ ! -f /etc/secureboot/GUID ]; then
                  sbctl create-keys
                  # sbctl enroll-keys --tpm-eventlog
                  # reboot
                  touch /create
                fi

                if mokutil --sb-state | grep -q disabled; then
                  chattr -i /sys/firmware/efi/efivars/{KEK,db}-*
                  sbctl enroll-keys --tpm-eventlog
                  touch /enroll
                elif [ ! -f /persist/jwt ]; then
                  key="$(mktemp feengold.XXXXXXXX)"
                  trap 'rm "$key"' EXIT
                  head -c 32 /dev/urandom > "$key"
                  clevis encrypt tpm2 \
                    '{"pcr_ids":"7","pcr_bank":"sha256"}' \
                    < "$key" \
                    > /persist/jwt
                  touch /encrypt
                  # zfs change-key rpool/nixos -o keylocation=prompt < "$key"
                fi
              '';
            };
          in
          "${program}/bin/${name}";

        environment.etc."machine-id".text = machine-id;
        networking.hostId = builtins.substring 0 8 machine-id;
      })
  ];
}
