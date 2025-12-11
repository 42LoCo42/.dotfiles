{ pkgs, lib, ... }:
let
  inherit (lib) getExe mkOption;
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
      default = import ../../homepage pkgs;
    };

    postgres = mkOption {
      type = package;
    };
  };

  config = {
    system.extraDependencies = with pkgs; [ pug ];

    aquaris = {
      users.admin.sshKeys = map
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

    rice = {
      domain = "eleonora.gay";
      nixremote.act = true;
    };

    networking.networkmanager.enable = false;

    # if caddy or headscale restarts, our tailscale nodes drop out of the network
    # and need to be restarted (including the autoconnect oneshot on the host)
    systemd.services =
      let
        units = [
          "podman-tscaddy.service"
          "tailscaled-autoconnect.service"
          "tailscaled.service"
        ];

        cfg = {
          before = units;
          requiredBy = units;
        };
      in
      {
        podman-caddy = cfg;
        podman-headscale = cfg;

        # so it actually gets restarted properly
        tailscaled-autoconnect.serviceConfig.RemainAfterExit = true;
      };

    environment.systemPackages = with pkgs; [
      (writeShellApplication {
        name = "normalize";
        runtimeInputs = [ exiftool parallel ];
        text = builtins.readFile ./normalize.sh;
      })

      immich-folder-album-creator
    ];

    home-manager.sharedModules = [{
      aquaris.persist = {
        "hidden" = { };
        "img" = { };
      };
    }];
  };
}
