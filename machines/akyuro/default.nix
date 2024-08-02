{ self, pkgs, config, lib, aquaris, ... }: {
  imports = [ "${self}/rice" ];

  aquaris = {
    machine = {
      id = "86b0e292e1fc27eb4168defa65cb41fd";
      key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBdZDuw+7O6+pV13ObPR/H4P8UCc1FzPmkufeaiJUc75";
    };

    users = aquaris.lib.merge [
      { inherit (aquaris.cfg.users) leonsch; }
      { leonsch.admin = true; }
    ];

    filesystems = { fs, ... }: {
      disks."/dev/disk/by-id/nvme-eui.8ce38e0400d8442a".partitions = [
        {
          type = "uefi";
          size = "512M";
          content = fs.regular {
            type = "vfat";
            mountpoint = "/boot";
          };
        }
        # btrfs-on-LUKS partition, see hardware.nix
      ];
    };

    secrets."users/leonsch/secretKey".user = "leonsch";
  };

  boot = {
    binfmt.emulatedSystems = [ "aarch64-linux" ];
    kernelPackages = config.boot.zfs.package.latestCompatibleLinuxPackages;
    supportedFilesystems.zfs = true;
  };

  hardware = {
    bluetooth = {
      enable = true;
      settings.General.Experimental = true;
    };

    firmware = with pkgs; lib.mkForce [
      linux-firmware
    ];
  };

  rice = {
    fuzzel-font-size = 14;
    temp-select = ''DRIVERS=="k10temp"'';
    temp-warn = 60;

    hypr-early-config = ''
      monitor = eDP-1,1920x1080@60,0x0,1
    '';
  };

  home-manager.users.leonsch = hm: {
    # TODO
    aquaris.emacs.enable = lib.mkForce false;
    programs.emacs = {
      enable = true;
      package = pkgs.emacs29-pgtk;
    };

    services.mako.extraConfig = ''
      [app-name=remo]
      on-notify=exec ${pkgs.mpv}/bin/mpv --volume=125 ~/sounds/exclamation.wav
      on-button-left=exec ${pkgs.mako}/bin/makoctl dismiss -n "$id" && ${pkgs.netcat}/bin/nc -dU /tmp/remo
    '';

    systemd.user.tmpfiles.rules =
      let home = hm.config.home.homeDirectory; in [
        "L+ ${home}/.ssh/id_ed25519 - - - - ${config.aquaris.secrets."users/leonsch/secretKey"}"
      ];
  };
}
