{ pkgs, config, aquaris, ... }: {
  imports = [ ../../rice ];

  aquaris = {
    users = aquaris.lib.merge [
      { inherit (aquaris.cfg.users) leonsch; }
      { leonsch.admin = true; }
    ];

    machine.id = "86b0e292e1fc27eb4168defa65cb41fd";

    filesystems = { fs, ... }: {
      zpools.rpool = fs.defaultPool;

      disks."/dev/disk/by-id/nvme-eui.8ce38e0400d8442a".partitions = [
        fs.defaultBoot
        {
          content = fs.luks {
            content = fs.zpool (p: p.rpool);
          };
        }
      ];
    };

    persist = {
      enable = true;
      dirs = [ "/root/.android" ];
    };

    # TODO secretKey handling should be part of aquaris
    secrets."user:leonsch.ssh-ed25519".user = "leonsch";
    secrets."user:leonsch.u2f-keys".user = "leonsch";
  };

  boot = {
    kernelPackages = pkgs.linuxPackages_zen;
    zfs.package = pkgs.zfs_unstable;
  };

  hardware.bluetooth = {
    enable = true;
    settings.General.Experimental = true;
  };

  services.auto-cpufreq.enable = true;

  rice = {
    desktop = true;

    dns = true;
    dnsmasq-interface = "wlp2s0";

    syncthing = true;
    tailscale = true;

    fuzzel-font-size = 14;
    temp-select = ''DRIVERS=="k10temp"'';
    temp-warn = 60;

    hypr-early-config = ''
      monitor = eDP-1,1920x1080@60,0x0,1
    '';
  };

  home-manager.users.leonsch = hm: {
    home.packages = with pkgs; [
      openvpn # for corporate VPN
      p7zip
      pwgen
      python3
      rustdesk-flutter
      wf-recorder

      # for external backup SSD
      btrfs-progs
      cryptsetup

      # for managing my music library
      ffmpeg
      kid3-cli
      moreutils
    ];

    home.sessionVariables.NIXOS_CONFIG_DIR = "$(realpath $HOME/config)";

    systemd.user.tmpfiles.rules =
      let
        home = hm.config.home.homeDirectory;
        sync = "${config.aquaris.persist.root}/${home}/sync";
      in
      (map (x: "L+ ${home}/${x} - - - - ${sync}/${x}") [
        "IU"
        "dev"
        "doc"
        "img"
        "work"
      ]) ++ [
        "L+ ${home}/config - - - - ${sync}/dev/nix/dotfiles"

        # TODO secretKey handling should be part of aquaris
        "L+ %h/.config/Yubico/u2f_keys - - - - ${config.aquaris.secrets."user:leonsch.u2f-keys"}"
        # "L+ %h/.ssh/id_ed25519         - - - - ${config.aquaris.secrets."user:leonsch.ssh-ed25519"}"
      ];
  };
}
