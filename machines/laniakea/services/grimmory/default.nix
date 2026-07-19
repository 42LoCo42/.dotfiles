{ config, pkgs, ... }: {
  topology.self.services.grimmory = {
    name = "Grimmory";
    icon = "services.grimmory";
    info = "Personal library management";
    details.url.text = "https://books.laniakea";
  };

  virtualisation.pnoc.grimmory = {
    path = with pkgs; [
      grimmory
      temurin-jre-bin-25
    ];

    script = ''
      exec grimmory /data
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
