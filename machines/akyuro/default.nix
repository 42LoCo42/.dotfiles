{ self, nixpkgs, my-utils }@args: nixpkgs.lib.nixosSystem rec {
  system = "x86_64-linux";
  specialArgs = args // my-utils system;
  modules = [
    ./hardware.nix
    self.inputs.home-manager.nixosModules.home-manager
    self.inputs.nix-index-database.nixosModules.nix-index
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
      networking.hostName = "akyuro";
      machine-id = "a68e65917ee5417a93bcd77aeb5f1a66";

      programs.command-not-found.enable = false;
      services.fwupd.enable = true;

      home-manager.users.default = { pkgs, config, ... }: {
        home.file.".ghci".text = ''
          :set -Wall
          :set -Wno-type-defaults
          :set prompt "[1;35mλ>[m "
        '';
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
