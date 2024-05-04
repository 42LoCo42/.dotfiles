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

  networking.firewall.trustedInterfaces = [ "virbr0" ];

  virtualisation.libvirtd = {
    enable = true;
    qemu.swtpm.enable = true;
  };

  hardware.bluetooth = {
    enable = true;
    settings.General.Experimental = true;
  };

  users.users.leonsch.extraGroups = [ "libvirtd" ];
  home-manager.users.leonsch = { ... }: {
    home.packages = with pkgs; [ virt-manager ];

    programs.firefox.package = pkgs.firefox.override
      { cfg.speechSynthesisSupport = false; };

    services.mako.extraConfig = ''
      [app-name=remo]
      on-notify=exec ${pkgs.mpv}/bin/mpv --volume=125 ~/sounds/exclamation.wav
      on-button-left=exec ${pkgs.mako}/bin/makoctl dismiss -n "$id" && ${pkgs.netcat}/bin/nc -dU /tmp/remo
    '';
  };
}
