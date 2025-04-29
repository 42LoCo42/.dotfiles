{ pkgs, lib, ... }:
let
  inherit (lib) mkOption pipe;
  inherit (lib.types) package;
in
{
  imports = [
    ../../profiles/server
    ./services
  ];

  options.rice = {
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

    rice.domain = "eleonora.gay";

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
