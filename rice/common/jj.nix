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
        # show template
        jst() {
          jj log --limit 1 --no-graph --ignore-working-copy -T "$@"
        }

        # bookmark find
        jbf() {
          commit="@"
          while true; do
            bookmarks=()

            jst 'self.bookmarks().map(|x| x.name() ++ "\n").join("")' -r "$commit" \
            | while read -r line; do bookmarks+=("$line"); done

            case "''${#bookmarks[@]}" in
              0) commit="$commit-" ;;

              1)
                echo "''${bookmarks[1]}"
                return 0
              ;;

              *)
                id="$(jst 'self.change_id().shortest(8) ++ "\n"' -r "$commit" --color always)"
                echo "[1;31mMore than 1 bookmark at commit[m $id"

                jst 'self.change_id().shortest(8)' -r "$commit" \
                | xargs -I% jj log --ignore-working-copy -r "%-..@"

                return 1
              ;;
            esac
          done
        }

        # "intelligent" push - sets bookmark-find to first non-empty commit
        jps() {
          bookmark="$(jbf)" || return 1

          commit="@"
          while "$(jst 'self.empty()' -r "$commit")"; do commit="$commit-"; done

          jj bookmark set "$bookmark" -r "$commit"
          jj git push
        }

        # clone from github
        jcg() {
          repo="git@github.com:$1"
          shift
          jj git clone --colocate "$repo" "$@"
        }

        # describe-then-new
        jdn() {
          jj describe -m "$@"
          jj new
        }

        ##### functions for magic enter #####

        # check root
        jcr() {
          jj root >/dev/null 2>&1
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
        jbs = "jj bookmark set";
        jbt = "jj bookmark track";
        jc = "jj git clone --colocate";
        jd = "jj describe -m";
        jdi = "jj diff";
        je = "jj edit";
        jfs = "jj file show";
        ji = "jj git init --colocate";
        jl = "jj log";
        jla = "jj log -r ::";
        jlr = "jj log --reversed";
        jn = "jj new";
        jnm = "jj new -m";
        jol = "jj op log";
        jor = "jj op restore";
        jos = "jj op show";
        jou = "jj op undo";
        jpl = "jj git fetch"; # "pull"
        jpu = "jj git push"; # jps is intelligent push
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
        jun = "jj undo";
      };
    })
  ];
}
