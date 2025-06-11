{ self, ... }: {
  nixpkgs.overlays = [
    (_: pkgs:
      let obscura = self.inputs.obscura.packages.${pkgs.system}; in {
        # nix-tree needs mainline nix,
        # since lix has a different path-info output format
        nix-tree = (pkgs.runCommand "nix-tree" {
          nativeBuildInputs = with pkgs; [ makeBinaryWrapper ];
        }) ''
          mkdir -p $out/bin
          makeWrapper ${pkgs.lib.getExe pkgs.nix-tree} $out/bin/nix-tree \
            --prefix PATH : ${pkgs.nix}/bin
        '';

        # https://github.com/z4yx/pam_rssh/commit/083d69962084a1515b357009bd26407a9c47b67c
        pam_rssh = pkgs.pam_rssh.overrideAttrs (old: {
          src = pkgs.fetchFromGitHub {
            inherit (old.src) owner repo fetchSubmodules;
            rev = "083d69962084a1515b357009bd26407a9c47b67c";
            hash = "sha256-VxbaxqyIAwmjjbgfTajqwPQC3bp7g/JNVNx9yy/3tus=";
          };
        });

        # immich is missing esbuild for architectures other than x86_64-linux
        # fluent-ffmpeg can cause crashes on some error messages
        # fixed in https://github.com/fluent-ffmpeg/node-fluent-ffmpeg/pull/1321
        immich = pkgs.immich.overrideAttrs (new: old: {
          prePatch = (old.prePatch or "") + ''
            cp ${new.npmDeps}/package-lock.json .
          '';

          npmDeps = pkgs.fetchNpmDeps {
            name = "${old.pname}-${old.version}-npm-deps";
            inherit (old) src;

            nativeBuildInputs = with pkgs; [ nodejs ];

            env.NODE_EXTRA_CA_CERTS =
              "${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt";

            patchPhase = ''
              export HOME="$TMP"
              npm install --save-exact --package-lock-only \
                esbuild@0.23.0 \
                ${builtins.concatStringsSep "" [
                  "fluent-ffmpeg"
                  "@github:fluent-ffmpeg/node-fluent-ffmpeg"
                  "#bfc99125d3d1885c01254d47b6403c2efe9df32a"
                ]}
            '';

            hash = "sha256-TXVNqx02D9NzsDOX2KAXPy2EBilH6R+tkGliTxa/RKM=";
          };
        });

        # we can't just call swaybg with GDK_PIXBUF_MODULE_FILE,
        # since it's already wrapped with that, so override that wrapping
        # taken from https://github.com/NixOS/nixpkgs/pull/322045
        swaybg = pkgs.swaybg.overrideAttrs (old: {
          nativeBuildInputs = (old.nativeBuildInputs or [ ]) ++ (with pkgs; [
            makeBinaryWrapper
            wrapGAppsNoGuiHook
          ]);

          postInstall =
            let
              loaders = pkgs.gnome._gdkPixbufCacheBuilder_DO_NOT_USE {
                extraLoaders = with pkgs; [
                  webp-pixbuf-loader
                ];
              };
            in
            ''
              export GDK_PIXBUF_MODULE_FILE="${loaders}"
            '';

          preFixup = ''
            makeWrapperArgs+=("''${gappsWrapperArgs[@]}")
          '';

          postFixup = ''
            wrapProgram $out/bin/swaybg ''${makeWrapperArgs[@]}
          '';
        });

        # default foot is opaque on fullscreen
        foot = obscura.foot-transparent;

        # default waybar always shows IPv6 in network module
        # https://github.com/Alexays/Waybar/pull/3959
        # https://github.com/Alexays/Waybar/commit/5e4dac1c0aebd6c4ad1f358f09e1cfd06a95d529
        waybar = obscura.waybar-ipfix;

        # obscura inclusion
        inherit (obscura)
          caddyfile-language-server
          chronometer
          email-oauth2-proxy
          ferroxide
          flameshot-grim
          glfw3-minecraft-extra
          ncps-db-helper
          photoview
          pinlist
          pug
          rustdesk-api
          socket-activate
          vencloud
          zfullfs
          ;
      })
  ];
}
