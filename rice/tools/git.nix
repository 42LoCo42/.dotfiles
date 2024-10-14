{ pkgs, lib, aquaris, ... }: {
  home-manager.sharedModules = [
    (hm:
      let
        inherit (lib) mkForce;

        allowedSigners = pkgs.writeText "allowedSigners" ''
          ${hm.config.programs.git.userEmail} namespaces="git" ${aquaris.cfg.mainSSHKey}
        '';
      in
      {
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

          gpg.enable = mkForce false;
        };
      })
  ];
}
