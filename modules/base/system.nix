{ self, ... }: {
  system.stateVersion = "23.11";
  zramSwap.enable = true;

  console.keyMap = "de-latin1";
  i18n.defaultLocale = "en_US.UTF-8";
  time.timeZone = "Europe/Berlin";


  system.activationScripts.link-current-config.text = ''
    rm -rf /etc/nixos
    ln -s "${self}" /etc/nixos
  '';

  services = {
    openssh = {
      enable = true;
      settings = {
        PasswordAuthentication = false;
        PermitRootLogin = "no";
      };
      hostKeys = [{
        path = "/etc/ssh/ssh_host_ed25519_key";
        type = "ed25519";
      }];
    };

    pipewire = {
      enable = true;
      alsa.enable = true;
      pulse.enable = true;
    };

    tlp.enable = true;
    journald.extraConfig = "SystemMaxUse=500M";
  };

  systemd = {
    extraConfig = "DefaultTimeoutStopSec=10s";

    network.wait-online.enable = false;
    services."NetworkManager-wait-online".enable = false;
  };
}
