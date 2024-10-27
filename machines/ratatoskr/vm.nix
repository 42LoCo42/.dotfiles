{ pkgs, lib, modulesPath, ... }:
let
  wanIF = "eth0";
  lanIF = "wlan0";
in
{
  virtualisation.vmVariant = {

    ##### hardware #####

    imports = [ (modulesPath + "/profiles/qemu-guest.nix") ];

    virtualisation = {
      cores = 8;
      graphics = false;
      memorySize = 8192;
    };

    boot = {
      initrd = {
        availableKernelModules = [ "ahci" "xhci_pci" "virtio_pci" "sr_mod" "virtio_blk" ];
        kernelModules = [ "kvm-amd" "mac80211_hwsim" ];
      };

      extraModprobeConfig = ''
        options mac80211_hwsim radios=2
      '';
    };

    ##### main #####

    rice = rec {
      inherit lanIF wanIF;
      acceptLocals = true;
      dnsmasq-interface = lanIF;
      hideSSID = false;
      tailscale = lib.mkForce false;
    };

    environment.systemPackages = with pkgs; [ iw ];

    systemd.services.lan = {
      serviceConfig = {
        PrivateNetwork = true;

        ExecStartPre = lib.getExe (pkgs.writeShellApplication {
          name = "lan-pre";
          runtimeInputs = with pkgs; [ iw util-linux ];
          text = ''
            nsenter -t 1 -m -n iw phy phy1 set netns $$
          '';
        });

        ExecStart = lib.getExe (pkgs.writeShellApplication {
          name = "lan";
          runtimeInputs = with pkgs; [ gawk wpa_supplicant ];
          text = ''
            pass="$(awk -F '|' 'NR == 1 {print $1}' /run/aqs/machine/sae-password)"

            ${pkgs.busybox}/bin/udhcpc -f -i wlan1 &

            wpa_supplicant -i wlan1 -c /dev/stdin <<EOF
              network={
                ssid="Ratatoskr"
                key_mgmt=SAE
                sae_password="$pass"
                ieee80211w=2
              }
            EOF
          '';
        });
      };

      wantedBy = [ "default.target" ];
    };

    users.users.admin.hashedPasswordFile = lib.mkForce "${pkgs.writeText "pw" ''
      $y$j9T$MDx6aUpgMqUyqe.MBKZ0l1$VndyAZntdKp4XM6J2LjQBhufU7NwWXC5M8NUptAHRQB
    ''}";
  };
}
