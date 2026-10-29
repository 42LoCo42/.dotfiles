{ aquaris, config, lib, pkgs, ... }:
let
  inherit (lib) getExe mkOption;
  inherit (lib.types) package;
in
{
  imports = [ ../../profiles/server ];

  options.rice = {
    homepage = mkOption {
      type = package;
      default = import ../../homepage pkgs;
    };
  };

  config = {
    system.extraDependencies = with pkgs; [ pug ];

    aquaris = {
      users = {
        admin.sshKeys = map
          (x: ''command="${getExe pkgs.rrsync} ${x.dir}",restrict ${x.key}'') [
          {
            dir = "/persist/home/admin/firefox/";
            key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIInpOfiVpjqdtV7KEZJ6PLBJ2a0Iu9tYdwufZpl/qOBD";
          }
          {
            dir = "/persist/home/admin/hidden/pizza.d/";
            key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAATS/nPcQRUHbhvJG3TAqMFVxI1UW3LFxYaXkf3kxDE";
          }
        ];

        mel = aquaris.cfg.users.mel // { nopass = true; };
      };

      machine = {
        id = "488cb972c1ac70db8307933f65d5defc";
        secureboot = false;
      };

      filesystems = { fs, ... }: {
        disks."/dev/disk/by-id/scsi-36024c6ac39264da98ce1a64b9fab7a20".partitions = [
          fs.defaultBoot
          { content = fs.zpool (p: p.rpool); }
        ];
      };
    };

    rice = {
      domain = "eleonora.gay";

      nixremote.act = true;

      tailscale = {
        enable = true;
        acceptDNS = true;
        isExit = true;
        hostname = "exit";
      };

      oci-firewall = {
        enable = true;

        auth = {
          fingerprint = "d5:b3:a1:42:61:b5:c0:bf:22:3c:1a:42:19:58:75:98";
          keyFile = config.aquaris.secret "@machine/oci";
          list = "ocid1.securitylist.oc1.eu-frankfurt-1.aaaaaaaan4azexkwqeiiv6harwzrjzz2zabyb57pb7zvj2hjqs2ddlgat4ea";
          region = "eu-frankfurt-1";
          tenancy = "ocid1.tenancy.oc1..aaaaaaaasvxixm7wontje3bfxrec77clnukuepshcmkti27whgnw25tv75qa";
          user = "ocid1.user.oc1..aaaaaaaabmroiepvsbo4swwysx3tmxrk42cai6tygpkun3n5uxpdjwmmyftq";
        };

        rules = [
          { desc = "Miscellaneous"; type = "tcp"; port = 37812; }
        ];
      };
    };

    nix.settings = {
      allowed-users = [ "mel" ];

      # disable pasta, it massively slows down & timeouts caddy's src fetch
      pasta-path = "";
    };

    networking.networkmanager.enable = false;

    environment.systemPackages = with pkgs; [
      (writeShellApplication {
        name = "normalize";
        runtimeInputs = [ exiftool parallel ];
        text = builtins.readFile ./normalize.sh;
      })

      immich-folder-album-creator
    ];

    systemd.services.tailscaled = {
      after = [ "podman-headscale.service" ];
      wants = [ "podman-headscale.service" ];

      serviceConfig.ExecStartPre = getExe (pkgs.writeShellApplication {
        name = "tailscale-cleanup";

        runtimeInputs = with pkgs; [
          findutils # xargs
          jq
          podman
        ];

        text = ''
          podman exec headscale headscale nodes list --output json \
          | jq '.[] | select(.name == "exit").id' \
          | xargs -I% podman exec headscale headscale nodes delete --force -i %
        '';
      });
    };

    home-manager.users = {
      admin = {
        aquaris.persist = {
          "hidden" = { };
          "img" = { };
        };
      };

      mel = {
        aquaris.persist = {
          "school" = { };
        };
      };
    };
  };
}
