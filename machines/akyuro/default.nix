{ self, nixpkgs }@args: nixpkgs.lib.nixosSystem {
  system = "x86_64-linux";
  specialArgs = args;
  modules = [
    ./hardware.nix
    self.inputs.home-manager.nixosModules.home-manager
    self.inputs.nix-index-database.nixosModules.nix-index
    self.inputs.lanzaboote.nixosModules.lanzaboote
    # self.inputs.obscura.nixosModules."9mount"

    "${self}/modules/base/all.nix"
    "${self}/modules/base/greeter.nix"
    "${self}/modules/boot/lanza.nix"
    "${self}/modules/boot/zfs.nix"
    "${self}/modules/home/hyprland.nix"
    "${self}/modules/home/terminal.nix"
    "${self}/modules/networking/bluetooth.nix"
    "${self}/modules/networking/default.nix"
    "${self}/modules/networking/tailscale.nix"
    "${self}/modules/security/u2f.nix"
    # "${self}/modules/virt/docker.nix"
    "${self}/modules/virt/libvirt.nix"

    ({ ... }: {
      networking = {
        hostName = "akyuro";
        hostId = "872955ae";
      };

      programs.command-not-found.enable = false;
      services.fwupd.enable = true;

      home-manager.users.default = { pkgs, config, ... }: {
        # systemd.user.services =
        #   let
        #     Install.WantedBy = [ "default.target" ];
        #     Environment = let user = config.home.username; in
        #       "PATH=/run/wrappers/bin:/home/${user}/.nix-profile/bin:/etc/profiles/per-user/${user}/bin:/nix/var/nix/profiles/default/bin:/run/current-system/sw/bin";
        #   in
        #   {
        #     remo-acceptor = {
        #       inherit Install;
        #       Service = {
        #         inherit Environment;
        #         ExecStart = "${config.home.homeDirectory}/dev/bash/remo-acceptor/remo-acceptor.sh";
        #       };
        #     };
        #   };

        services.syncthing.enable = true;

        services.mako.extraConfig = ''
          [app-name=remo]
          on-notify=exec ${pkgs.mpv}/bin/mpv ~/sounds/exclamation.wav
          on-button-left=exec ${pkgs.mako}/bin/makoctl dismiss -n "$id" && echo | ${pkgs.socat}/bin/socat UNIX-CONNECT:/tmp/remo -
        '';
      };
    })
  ];
}
