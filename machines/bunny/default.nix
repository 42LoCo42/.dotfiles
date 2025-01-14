{ self, pkgs, config, lib, aquaris, ... }:
let
  inherit (lib) concatMapStringsSep mkOption pipe splitString;
  inherit (lib.types) attrsOf functionTo package str;
in
{
  imports = [ ../../rice ./services ];

  options.rice = {
    obscura = mkOption {
      type = attrsOf package;
      default = self.inputs.obscura.packages.${pkgs.system};
    };

    domain = mkOption {
      type = str;
      default = "eleonora.gay";
    };

    dn = mkOption {
      type = str;
      default = pipe config.rice.domain [
        (splitString ".")
        (concatMapStringsSep "," (x: "dc=" + x))
      ];
    };

    subsDomain = mkOption {
      type = functionTo package;
      default = file: aquaris.lib.subsF {
        inherit file;
        func = pkgs.writeText;
        subs = { inherit (config.rice) domain dn; };
      };
    };

    invfork = mkOption {
      type = package;
      default = pkgs.runCommandCC "invfork"
        { nativeBuildInputs = with pkgs; [ musl ]; } ''
        cc -Wall -Wextra -Werror -O3 -static -flto ${./invfork.c} -o $out
        strip -s $out
      '';
    };

    homepage = mkOption {
      type = package;
      default =
        let
          iosevka = pipe pkgs.nerd-fonts [
            (x: x.iosevka)
            (x: "${x}/share/fonts/truetype/NerdFonts/Iosevka/IosevkaNerdFont-Regular.ttf")
          ];
        in
        pkgs.stdenvNoCC.mkDerivation {
          name = "homepage";
          src = let d = ../../homepage; in lib.fileset.toSource {
            root = d;
            fileset = d;
          };

          nativeBuildInputs = with pkgs; [
            config.rice.obscura.pug

            glibcLocales
            tree
            woff2
          ];

          buildPhase = ''
            cp -r static $out
            cp "${iosevka}" $out/iosevka.ttf
            woff2_compress $out/iosevka.ttf
            bash processStuff.sh
            pug3 -o $out .
          '';
        };
    };
  };

  config = {
    aquaris = {
      machine = {
        id = "488cb972c1ac70db8307933f65d5defc";
        secureboot = false;
      };

      users = aquaris.lib.merge [
        { inherit (aquaris.cfg.users) admin; }
        { admin.admin = true; }
      ];

      filesystems = { fs, ... }: {
        disks."/dev/disk/by-id/scsi-36024c6ac39264da98ce1a64b9fab7a20".partitions = [
          fs.defaultBoot
          { content = fs.zpool (p: p.rpool); }
        ];

        zpools.rpool = fs.defaultPool;
      };

      persist.enable = true;
    };

    rice.pam-rssh.enable = true;

    nix.gc.automatic = true;

    networking.networkmanager.enable = false;

    environment.systemPackages = [
      (pkgs.writeShellApplication {
        name = "normalize";
        runtimeInputs = with pkgs; [ exiftool parallel ];
        text = builtins.readFile ./normalize.sh;
      })
    ];

    home-manager.users.admin = {
      aquaris.persist = {
        "hidden" = { };
        "img" = { };
      };
    };
  };
}
