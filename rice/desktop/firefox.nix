{ lib, config, ... }: lib.mkIf config.rice.desktop {
  nixpkgs.overlays = [
    (_: pkgs: {
      firefox = pkgs.firefox.override { cfg.speechSynthesisSupport = false; };
    })
  ];

  # TODO build declarative ffox config
  home-manager.sharedModules = [{
    programs.firefox.enable = true;

    systemd.user.tmpfiles.rules = [
      "d %h/.local/share/pki       0700 - - - -"
      "d %h/.local/share/pki/nssdb 0700 - - - -"
    ];
  }];
}
