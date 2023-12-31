{ self, ... }: {
  system.stateVersion = "23.11";
  zramSwap.enable = true;

  console.keyMap = "de-latin1";
  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings.LC_TIME = "de_DE.UTF-8";
  time.timeZone = "Europe/Berlin";

  environment.etc.nixos.source = self;

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
    journald.extraConfig = "SystemMaxUse=100M";
  };

  systemd = {
    extraConfig = "DefaultTimeoutStopSec=10s";

    network.wait-online.enable = false;
    services."NetworkManager-wait-online".enable = false;
  };
}
