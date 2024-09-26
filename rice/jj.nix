{ lib, ... }: {
  home-manager.sharedModules = [
    ({ config, ... }: {
      programs.jujutsu = {
        enable = true;
        settings = {
          user = {
            name = config.programs.git.userName;
            email = config.programs.git.userEmail;
          };

          signing = {
            sign-all = true;
            backend = "ssh";
            key = "~/.ssh/id_ed25519";
          };
        };
      };

      programs.zsh.oh-my-zsh.extraConfig = lib.mkAfter ''
        MAGIC_ENTER_GIT_COMMAND=' if test -d .jj; then js; else git status; fi'
      '';

      home.shellAliases = {
        j = "jj";
        jbl = "jj branch list";
        jbs = "jj branch set";
        jd = "jj describe";
        jdm = "jj describe -m";
        je = "jj edit";
        jl = "jj log";
        jlr = "jj log --reversed";
        jn = "jj new";
        jnm = "jj new -m";
        jpl = "jj git fetch";
        jps = "jj git push";
        jr = "jj rebase";
        js = "jj status";
        jsp = "jj split";
        jspi = "jj split -i";
        jsq = "jj squash";
        jsqi = "jj squash -i";
      };
    })
  ];
}
