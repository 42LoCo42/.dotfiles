{ ... }: {
  virtualisation.docker.rootless = {
    enable = true;
    setSocketVariable = true;
  };

  home-manager.users.leonsch = { pkgs, ... }: {
    home.packages = with pkgs; [
      docker-client
    ];
  };
}
