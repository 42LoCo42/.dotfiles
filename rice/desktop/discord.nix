{ lib, config, ... }:
let
  inherit (lib) getExe mkIf pipe;
in
mkIf config.rice.desktop {
  nixpkgs.overlays = [
    (_: pkgs: {
      vesktop = pipe pkgs.vesktop [
        (x: x.override {
          withSystemVencord = false;
          withTTS = false;
        })
        # (x: x.overrideAttrs (old: {
        #   postFixup = old.postFixup + ''
        #     mv $out/bin/{vesktop,.vesktop-wrapped}
        #     makeWrapper                                                \
        #       ${getExe pkgs.boxxy}                                     \
        #       $out/bin/vesktop                                         \
        #       --add-flags --rule='~/.pki:~/.local/share/pki:directory' \
        #       --add-flags $out/bin/.vesktop-wrapped
        #   '';
        # }))
      ];
    })
  ];

  home-manager.sharedModules = [{
    aquaris.persist = [ ".config/vesktop" ];
  }];
}
