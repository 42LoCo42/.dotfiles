{ self, pkgs, lib, config, modulesPath, ... }: {
  virtualisation.vmVariant = {

    ##### hardware #####

    imports = [ (modulesPath + "/profiles/qemu-guest.nix") ];

    virtualisation = {
      cores = 8;
      # diskSize = 4096;
      graphics = false;
      memorySize = 8192;

      qemu.networkingOptions = [
        "-device vhost-vsock-pci,id=vwifi0,guest-cid=3"
      ];
    };

    boot = {
      initrd.availableKernelModules = [ "ahci" "xhci_pci" "virtio_pci" "sr_mod" "virtio_blk" ];

      kernelModules = [ "kvm-amd" "mac80211_hwsim" ];

      extraModprobeConfig = ''
        options mac80211_hwsim radios=0
      '';
    };

    ##### main #####

    systemd.services = {
      hostapd = {
        after = [ "vwifi-client.service" ];
        requires = [ "vwifi-client.service" ];
      };

      vwifi-client = {
        serviceConfig.ExecStart = "${self.inputs.obscura.packages.${pkgs.system}.vwifi}/bin/vwifi-client --number 1";
        wantedBy = [ "network-pre.target" ];
      };
    };

    rice = rec {
      wanIF = "eth0";
      lanIF = "wlan0";
      disk = "virtio-root";

      acceptLocals = true;

      dnsmasq-interface = lanIF;

      tailscale = lib.mkForce false;
    };

    networking = {
      networkmanager.unmanaged = [ config.rice.wanIF config.rice.lanIF ];
    };

    users.users.admin.hashedPasswordFile = lib.mkForce "${pkgs.writeText "pw" ''
      $y$j9T$MDx6aUpgMqUyqe.MBKZ0l1$VndyAZntdKp4XM6J2LjQBhufU7NwWXC5M8NUptAHRQB
    ''}";
  };
}
