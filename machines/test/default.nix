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

      # this fixes occasional "failures" of zfs-mount
      systemd.services."zfs-mount".serviceConfig.Restart = "on-failure";


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

    ({ pkgs, lib, config, ... }:
      let
        machine-id = "28b614da10fbda25dabb87d7653faf3a";
        initial = pkgs.writeText "initial-password" "feengold";
      in
      {
        imports = [ (import ./disk.nix { inherit initial; }) ];

        boot.initrd = {
          kernelModules = [ "tpm_crb" ];
          systemd.storePaths = [ initial ];
        };

        system.activationScripts.zfs-set-keylocation.text = ''
          ${pkgs.zfs}/bin/zfs set keylocation=file://${initial} rpool/nixos
        '';

        environment.etc."machine-id".text = machine-id;
        networking.hostId = builtins.substring 0 8 machine-id;

        # system.activationScripts.feengold =
        #   let
        #     name = "feengold-activation";
        #     program = pkgs.writeShellApplication {
        #       inherit name;
        #       runtimeInputs = with pkgs; [
        #         clevis
        #         e2fsprogs
        #         mokutil
        #         sbctl
        #         zfs
        #       ];
        #       text = ''
        #         [ -d /etc/nixos ] && [ ! -L /etc/nixos ] && rmdir /etc/nixos
        #         ln -sfT "${self}" /etc/nixos

        #         zfs change-key rpool/nixos -o keylocation=file://${initial}

        #         if [ ! -f /etc/secureboot/GUID ]; then
        #           sbctl create-keys
        #           touch /create
        #         fi

        #         if mokutil --sb-state | grep -q disabled; then
        #           for i in /sys/firmware/efi/efivars/{KEK,db}-*; do
        #             [ -e "$i" ] && chattr -i "$i"
        #           done
        #           sbctl enroll-keys --tpm-eventlog
        #           touch /enroll
        #         elif [ ! -f /persist/jwt ]; then
        #           key="$(mktemp feengold.XXXXXXXX)"
        #           trap 'rm "$key"' EXIT
        #           head -c 32 /dev/urandom > "$key"
        #           clevis encrypt tpm2 \
        #             '{"pcr_ids":"7","pcr_bank":"sha256"}' \
        #             < "$key" \
        #             > /persist/jwt
        #           touch /encrypt
        #           # zfs change-key rpool/nixos -o keylocation=prompt < "$key"
        #         fi
        #       '';
        #     };
        #   in
        #   "${program}/bin/${name}";
      })
  ];
}
