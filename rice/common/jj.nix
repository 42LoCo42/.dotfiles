{ lib, ... }: {
  environment.variables.LESS = "-i -F -R";

  home-manager.sharedModules = [
    ({ config, ... }: {
      programs.jujutsu = {
        enable = true;
        settings = lib.mkMerge [
          # TODO rework all of this...?
          (lib.mkIf (config.programs.git.userName != null)
            { user.name = config.programs.git.userName; })

          (lib.mkIf (config.programs.git.userEmail != null)
            { user.email = config.programs.git.userEmail; })

          (lib.mkIf (config.programs.git.signing.key != null) {
            signing = {
              sign-all = true;
              backend = "ssh";
              key = config.programs.git.signing.key;
            };
          })
        ];
      };

      programs.zsh.oh-my-zsh.extraConfig = lib.mkAfter ''
        # bookmark set: find first non-empty commit
        jbs() {
          commit="@"
          while [ "$(jj show -r "$commit" -T 'self.empty()' --tool true)" = "true" ]; do
            commit="$commit-"
          done
          jj bookmark set -r "$commit" "$@"
        }

        # clone from github
        jcg() {
          repo="git@github.com:$1"
          shift
          jj git clone --colocate "$repo" "$@"
        }

        # check root
        jcr() {
          jj root >/dev/null 2>&1
        }

        # describe-then-new
        jdn() {
          jj describe -m "$@"
          jj new
        }

        # status-then-log
        jsl() {
          jj status --no-pager
          echo
          jj log --no-pager
        }

        MAGIC_ENTER_GIT_COMMAND='   if jcr; then jsl; else git status; fi'
        MAGIC_ENTER_OTHER_COMMAND=' if jcr; then jsl; else l;          fi'
      '';

      home.shellAliases = {
        j = "jj";
        ja = "jj abandon";
        jbd = "jj bookmark delete";
        jbl = "jj bookmark list";
        jbla = "jj bookmark list --all";
        jbt = "jj bookmark track";
        jc = "jj git clone --colocate";
        jd = "jj diff";
        jdm = "jj describe -m";
        je = "jj edit";
        ji = "jj git init --colocate";
        jl = "jj log";
        jla = "jj log -r ::";
        jlr = "jj log --reversed";
        jn = "jj new";
        jnm = "jj new -m";
        jpl = "jj git fetch"; # "pull"
        jps = "jj git push";
        jr = "jj rebase";
        jra = "jj git remote add";
        jrd = "jj git remote remove"; # "delete"
        jrl = "jj git remote list";
        jrs = "jj git remote set-url";
        js = "jj show";
        jsp = "jj split";
        jspi = "jj split -i";
        jsq = "jj squash";
        jsqi = "jj squash -i";
        ju = "jj file untrack";
      };
    })
  ];
}
