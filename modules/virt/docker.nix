{ ... }: {
  virtualisation.docker.rootless = {
    enable = true;
    setSocketVariable = true;
  };

  home-manager.users.default = { pkgs, ... }: {
    home.packages = with pkgs; [
      docker-client
    ];
  };
}
