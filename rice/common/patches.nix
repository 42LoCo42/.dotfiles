{ self, ... }: {
  nixpkgs.overlays = [
    (_: pkgs:
      let obscura = self.inputs.obscura.packages.${pkgs.system}; in {
        nix-tree = (pkgs.runCommand "nix-tree" {
          nativeBuildInputs = with pkgs; [ makeBinaryWrapper ];
        }) ''
          mkdir -p $out/bin
          makeWrapper ${pkgs.lib.getExe pkgs.nix-tree} $out/bin/nix-tree \
            --prefix PATH : ${pkgs.nix}/bin
        '';

        pam_rssh = pkgs.pam_rssh.overrideAttrs (old: {
          src = pkgs.fetchFromGitHub {
            inherit (old.src) owner repo fetchSubmodules;
            rev = "083d69962084a1515b357009bd26407a9c47b67c";
            hash = "sha256-VxbaxqyIAwmjjbgfTajqwPQC3bp7g/JNVNx9yy/3tus=";
          };
        });

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

        foot = obscura.foot-transparent;
        waybar = obscura.waybar-ipfix;
      })
  ];
}
