{ pkgs, config, lib, aquaris, ... }:
let
  inherit (lib) flatten mkOption pipe;
  inherit (lib.types) functionTo listOf package str;
in
{
  imports = [
    ../../profiles/server
    ./services
  ];

  options.rice = {
    domain = mkOption {
      type = str;
      default = "eleonora.gay";
    };

    subsDomain = mkOption {
      type = functionTo package;
      default = file: aquaris.lib.subsF {
        inherit file;
        func = pkgs.writeText;
        subs = { inherit (config.rice) domain; };
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

    redis = mkOption {
      type = listOf str;
      default = flatten [
        [ (lib.getExe pkgs.tini) "--" ]
        (config.rice.invfork.outPath)
        (lib.getExe' pkgs.redis "redis-server")
        [ "--dir" "/data" ]
        [ "--bind" "127.0.0.1" ]
        "--"
      ];
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
            glibcLocales
            pug
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

      secrets.pub = "XWoKHGExV00G8lDsdZdfWkv99PDNUH0ukt-xjuv8Lzs";

      filesystems = { fs, ... }: {
        disks."/dev/disk/by-id/scsi-36024c6ac39264da98ce1a64b9fab7a20".partitions = [
          fs.defaultBoot
          { content = fs.zpool (p: p.rpool); }
        ];
      };
    };

    networking.networkmanager.enable = false;

    environment.systemPackages = [
      (pkgs.writeShellApplication {
        name = "normalize";
        runtimeInputs = with pkgs; [ exiftool parallel ];
        text = builtins.readFile ./normalize.sh;
      })
    ];

    home-manager.sharedModules = [{
      aquaris.persist = {
        "hidden" = { };
        "img" = { };
      };
    }];
  };
}
