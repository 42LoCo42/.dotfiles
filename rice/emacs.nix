{ pkgs, lib, ... }: {
  home-manager.sharedModules = [{
    aquaris.emacs = {
      enable = true;
      package = pkgs.emacs29-pgtk;
      config = ./emacs.org; # TODO one must imagine sisyphus happy
      extraPrograms = with pkgs; [
        clang-tools
        gopls
        haskell-language-server
        nodePackages.bash-language-server
        stylish-haskell
      ];
    };

    services.emacs.enable = true;
    systemd.user.services.emacs.Service.Restart = lib.mkForce "always";
  }];
}
