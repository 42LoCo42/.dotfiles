{
  nixpkgs.overlays = [
    (_: pkgs: {
      pam_rssh = pkgs.pam_rssh.overrideAttrs (old: {
        src = pkgs.fetchFromGitHub {
          inherit (old.src) owner repo fetchSubmodules;
          rev = "083d69962084a1515b357009bd26407a9c47b67c";
          hash = "sha256-VxbaxqyIAwmjjbgfTajqwPQC3bp7g/JNVNx9yy/3tus=";
        };
      });

      # TODO https://github.com/matt1432/nixos-configs/commit/4927481b255210aeda060e06d0a1a8cd68cd5ae1
      searxng = pkgs.searxng.override {
        # FIXME: https://github.com/NixOS/nixpkgs/issues/380351
        python3 = pkgs.python3.override {
          packageOverrides = _: pyPrev: {
            httpx = pyPrev.httpx.overridePythonAttrs (o: rec {
              version = "0.27.2";
              src = pkgs.fetchFromGitHub {
                owner = "encode";
                repo = o.pname;
                tag = version;
                hash = "sha256-N0ztVA/KMui9kKIovmOfNTwwrdvSimmNkSvvC+3gpck=";
              };
            });

            starlette = pyPrev.starlette.overridePythonAttrs (o: rec {
              version = "0.41.2";
              src = pkgs.fetchFromGitHub {
                owner = "encode";
                repo = "starlette";
                tag = version;
                hash = "sha256-ZNB4OxzJHlsOie3URbUnZywJbqOZIvzxS/aq7YImdQ0=";
              };
            });

            httpx-socks = pyPrev.httpx-socks.overridePythonAttrs (o: rec {
              version = "0.9.2";
              src = pkgs.fetchFromGitHub {
                owner = "romis2012";
                repo = "httpx-socks";
                tag = "v${version}";
                hash = "sha256-PUiciSuDCO4r49st6ye5xPLCyvYMKfZY+yHAkp5j3ZI=";
              };
            });
          };
        };
      };
    })
  ];
}
