{ pkgs, lib, config, ... }: {
  options.rice.desktop.vesktop.enable = lib.mkOption {
    type = lib.types.bool;
    default = false;
  };

  config = lib.mkIf config.rice.desktop.vesktop.enable {
    home-manager.sharedModules = [{
      aquaris.persist = { ".config/vesktop" = { }; };
      programs.vesktop = {
        enable = true;
        vencord.useSystem = true;

        package = pkgs.vesktop.override {
          vencord = pkgs.vencord.overrideAttrs (old: {
            patches = (old.patches or [ ]) ++ [
              ./0001-add-private-domains-to-CSP.patch
            ];

            preBuild = (old.preBuild or "") + ''
              install -Dm444 ${pkgs.fetchurl {
                url = "https://raw.githubusercontent.com/Vendicated/Vencord/d7e6fcd3ae2dad93a27348e683453a4c912208e8/src/plugins/moyai/index.ts";
                hash = "sha256-+Y5AcOfCddi/jhY/SVFgwytXnd3B1Q5bbHcf3KypWBA=";
              }} src/plugins/moyai/index.ts
            '';
          });

          withSystemVencord = true;
          withTTS = false;
        };
      };
    }];
  };
}
