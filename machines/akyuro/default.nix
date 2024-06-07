{ self, pkgs, config, lib, ... }: {
  imports = [ "${self}/rice" ];

  hardware.firmware = with pkgs; lib.mkForce [ linux-firmware ];

  aquaris = {
    persist.enable = false;
    filesystem = { };
    # filesystem = { filesystem, zpool, ... }: {
    #   disks."/dev/disk/by-id/nvme-eui.8ce38e0400d8442a".partitions = [
    #     {
    #       type = "uefi";
    #       size = "512M";
    #       content = filesystem {
    #         type = "vfat";
    #         mountpoint = "/boot";
    #       };
    #     }
    #     { content = zpool (p: p.rpool); }
    #   ];

    #   zpools.rpool.datasets =
    #     { "nixos/nix" = { }; } //
    #     (lib.mapAttrs'
    #       (_: user: {
    #         name = "nixos${config.aquaris.persist.root}/home/${user.name}";
    #         value = { };
    #       })
    #       config.aquaris.users);
    # };
  };

  hardware.bluetooth = {
    enable = true;
    settings.General.Experimental = true;
  };

  programs = {
    nix-ld.enable = true;
    gamemode.enable = true;
  };

  home-manager.users.leonsch = { ... }: {
    services.mako.extraConfig = ''
      [app-name=remo]
      on-notify=exec ${pkgs.mpv}/bin/mpv --volume=125 ~/sounds/exclamation.wav
      on-button-left=exec ${pkgs.mako}/bin/makoctl dismiss -n "$id" && ${pkgs.netcat}/bin/nc -dU /tmp/remo
    '';
  };
}
