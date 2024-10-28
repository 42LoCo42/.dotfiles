{ pkgs, lib, config, ... }:
let inherit (lib) getExe mkForce; in {
  virtualisation.vmVariant = {

    ##### hardware #####

    virtualisation = {
      cores = 4;
      graphics = false;
      memorySize = 8192;
    };

    boot = {
      kernelModules = [ "mac80211_hwsim" ];

      extraModprobeConfig = ''
        options mac80211_hwsim radios=2
      '';
    };

    ##### main #####

    services.router = {
      lanIF = mkForce "wlan0";
      wanIF = mkForce "eth0";
    };

    environment.systemPackages = with pkgs; [ iw ];

    systemd.services.lan = {
      serviceConfig = {
        PrivateNetwork = true;

        ExecStartPre = getExe (pkgs.writeShellApplication {
          name = "lan-pre";
          runtimeInputs = with pkgs; [ iw util-linux ];
          text = ''
            nsenter -t 1 -m -n iw phy phy1 set netns $$
          '';
        });

        ExecStart = getExe (pkgs.writeShellApplication {
          name = "lan";
          runtimeInputs = with pkgs; [ gawk wpa_supplicant ];
          text = let sec = config.aquaris.secrets."machine/sae-password"; in ''
            pass="$(awk -F '|' 'NR == 1 {print $1}' ${sec})"

            ${pkgs.busybox}/bin/udhcpc -f -i wlan1 &

            wpa_supplicant -i wlan1 -c /dev/stdin <<EOF
              network={
                ssid="${config.services.router.wlan.ssid}"
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

    users.users.admin.hashedPasswordFile = mkForce "${pkgs.writeText "pw" ''
      $y$j9T$MDx6aUpgMqUyqe.MBKZ0l1$VndyAZntdKp4XM6J2LjQBhufU7NwWXC5M8NUptAHRQB
    ''}";
  };
}
