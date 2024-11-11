{
  nixpkgs.overlays = [
    (_: pkgs: {
      # https://nixpk.gs/pr-tracker.html?pr=355129
      vaultwarden = pkgs.vaultwarden.overrideAttrs (old: rec {
        version = "1.32.4";

        src = pkgs.fetchFromGitHub {
          inherit (old.src) owner repo;
          rev = version;
          hash = "sha256-fT1o+nR7k1fLFS4TeoP1Gm1P0uLTu6Dai6hMGraAKjE=";
        };

        cargoDeps = pkgs.rustPlatform.fetchCargoTarball {
          inherit src;
          hash = "sha256-9PIl1VycDjwWL4ZcGRaO8tpG2DlwtJWYmq3R7SncQBE=";
        };

        env.VW_VERSION = version;
      });
    })
  ];
}
