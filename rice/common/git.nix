{ pkgs, lib, config, ... }: {
  home-manager.sharedModules = [
    (hm:
      let
        inherit (lib) mkForce mkIf;

        name = hm.config.home.username;
        user = config.aquaris.users.${name}.git;

        allowedSigners = pkgs.writeText "allowedSigners" ''
          ${user.email} namespaces="git" ${user.key}
        '';
      in
      mkIf (user.key != null) {
        programs = {
          git = {
            extraConfig = {
              gpg = {
                format = "ssh";
                ssh.allowedSignersFile = "${allowedSigners}";
              };

              merge.tool = "vimdiff";
            };

            signing.key = mkForce "~/.ssh/id_ed25519";
          };
        };
      })
  ];
}
