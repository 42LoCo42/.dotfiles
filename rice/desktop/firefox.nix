{ config, lib, ... }: {
  options.rice.desktop.firefox.enable = lib.mkOption {
    type = lib.types.bool;
    default = false;
  };

  config = lib.mkIf config.rice.desktop.firefox.enable {
    home-manager.sharedModules = [{
      aquaris.firefox = {
        enable = true;

        prefs = {
          # can't connect to livekit calls when DTLS v1.3 (772) is enabled
          # https://bugzilla.mozilla.org/show_bug.cgi?id=2033783
          "media.peerconnection.dtls.version.max" = 771;

          "identity.fxaccounts.enabled" = true;
          "identity.sync.tokenserver.uri" = "https://firefox-sync.bunny/1.0/sync/1.5";
          "services.sync.engine.passwords" = false;

          "services.sync.extension-storage.skipPercentageChance" = 0;
          "services.sync.scheduler.activeInterval" = 10;
          "services.sync.scheduler.fxa.singleDeviceInterval" = 10;
          "services.sync.scheduler.idleInterval" = 10;
          "services.sync.scheduler.idleTime" = 10;
          "services.sync.scheduler.immediateInterval" = 10;
        };

        policies = {
          DisableFirefoxAccounts = lib.mkForce false;
        };
      };
    }];
  };
}
