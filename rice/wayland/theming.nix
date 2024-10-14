{ pkgs, ... }: {
  home-manager.sharedModules = [{
    gtk = let dark = { gtk-application-prefer-dark-theme = true; }; in {
      enable = true;
      theme.name = "Adwaita";

      gtk3.extraConfig = dark;
      gtk4.extraConfig = dark;
    };

    qt = {
      enable = true;
      platformTheme.name = "gtk3";
      style.name = "adwaita-dark";
    };

    home.packages = with pkgs; [
      kdePackages.qtwayland # qt6
      qt5.qtwayland
    ];
  }];
}
