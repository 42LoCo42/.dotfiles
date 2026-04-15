{ pkgs, config, ... }: {
  virtualisation.pnoc.grimmory = {
    path = with pkgs; [ temurin-jre-bin-25 ];

    script = ''
      exec java                              \
        -Dapp.path-config=/data/app          \
        -Dapp.bookdrop-folder=/data/bookdrop \
        -jar ${pkgs.grimmory}/grimmory.jar
    '';

    environment = {
      BOOKLORE_PORT = "8080";

      DATABASE_URL = "jdbc:mariadb://mariadb:3306/grimmory";
      DATABASE_USERNAME = "grimmory";
    };

    environmentFiles = [ (config.aquaris.secret "@machine/grimmory") ];

    volumes = [ "grimmory:/data" ];
  };
}
