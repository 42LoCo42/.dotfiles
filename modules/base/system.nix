{ pkgs, ... }: {
  system.stateVersion = "23.11";
  zramSwap.enable = true;

  console.keyMap = "de-latin1";
  i18n.defaultLocale = "en_US.UTF-8";
  time.timeZone = "Europe/Berlin";

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

    greetd = {
      enable = true;
      restart = true;
      vt = 7;
      settings.default_session.command =
        "${pkgs.greetd.tuigreet}/bin/tuigreet -tr --remember-user-session";
    };

    tlp.enable = true;
    journald.extraConfig = "SystemMaxUse=500M";
  };

  systemd = {
    extraConfig = "DefaultTimeoutStopSec=10s";

    network.wait-online.enable = false;
    services."NetworkManager-wait-online".enable = false;

    tmpfiles.rules = [
      "d /var/cache/tuigreet 0755 greeter greeter"
    ];
  };
}
