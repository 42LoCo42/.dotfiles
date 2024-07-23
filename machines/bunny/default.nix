{ self, pkgs, config, lib, aquaris, obscura, ... }:
let
  inherit (lib) getExe getExe' pipe;

  domain = "eleonora.gay";
  subsDomain = file: aquaris.lib.subsF {
    inherit file;
    func = pkgs.writeText;
    subs = { inherit domain; };
  };

  iosevka = pipe pkgs.nerdfonts [
    (x: x.override { fonts = [ "Iosevka" ]; })
    (x: "${x}/share/fonts/truetype/NerdFonts/IosevkaNerdFont-Regular.ttf")
  ];

  homepage = pkgs.stdenvNoCC.mkDerivation {
    name = "homepage";
    src = let d = ../../homepage; in lib.fileset.toSource {
      root = d;
      fileset = d;
    };

    nativeBuildInputs = with pkgs; [ glibcLocales pug tree ];

    buildPhase = ''
      cp -r static $out
      cp "${iosevka}" $out/iosevka.ttf
      bash processStuff.sh
      pug3 -o $out .
    '';
  };

  avh = self.inputs.packages.${pkgs.system}.default;
in
{
  nixpkgs.overlays = [
    (_: _: {
      inherit (obscura.packages.${pkgs.system}) photoview pug;
    })
  ];

  aquaris = {
    machine = {
      id = "488cb972c1ac70db8307933f65d5defc";
      key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBbsL7HyOCM56ejtlWqEBG1YzQwX2KmZ3S5KzoGnWh/j";
      secureboot = false;
    };

    users = {
      admin = {
        admin = true;
        sshKeys = [ aquaris.cfg.mainSSHKey ];
      };

      coder = {
        sshKeys = [
          aquaris.cfg.mainSSHKey
          # "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPU1Mi6swudVo9JkJl8Og/fzr+gCJTQ2bK4qd652IOgz legacy"
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILckymOuvsGYKZxW2EuTaBoQUBaamDNCoCygxIWz/3cF francisco"
        ];
      };
    };

    filesystems = { fs, ... }: {
      disks."/dev/disk/by-id/scsi-36024c6ac39264da98ce1a64b9fab7a20".partitions = [
        {
          type = "uefi";
          size = "512M";
          content = fs.regular {
            type = "vfat";
            mountpoint = "/boot";
          };
        }
        { content = fs.zpool (p: p.rpool); }
      ];

      zpools.rpool = fs.defaultPool;
    };

    persist.enable = true;

    secrets = {
      "machine/synapse/secrets".user = "synapse";
      "machine/synapse/signing-key".user = "synapse";
    };
  };

  home-manager.users.admin.aquaris.persist = [
    "hidden"
    "img"
  ];

  nix.gc.automatic = true;

  system = {
    autoUpgrade = {
      enable = true;
      flake = "github:42loco42/.dotfiles";
      flags = [ "--refresh" "-L" ];
    };

    extraDependencies = with pkgs; [ avh photoview pug ];
  };

  networking = {
    firewall = {
      allowedTCPPorts = [ 80 443 ];
      allowedUDPPorts = [ 443 ];
    };

    networkmanager.enable = false;
  };

  services = {
    endlessh = {
      enable = true;
      port = 22;
      openFirewall = true;
      extraOptions = [ "-v" ];
    };

    openssh.ports = lib.mkForce [ 18213 ];

    zfs = {
      autoScrub = { enable = true; interval = "weekly"; };
      autoSnapshot.enable = true;
      trim.enable = true;
    };
  };

  systemd.services.podman-volume-setup.serviceConfig.Restart = lib.mkForce "on-failure";
  virtualisation.podman.defaultNetwork.settings.dns_enabled = true;

  virtualisation.pnoc = {
    caddy = {
      cmd = [ (getExe pkgs.caddy) "run" "-a" "caddyfile" "-c" "${./Caddyfile}" ];
      environment = {
        DOMAIN = domain;
        XDG_DATA_HOME = "/";
      };
      ports = [
        "80:8000"
        "443:4430"
        "443:4430/udp"
      ];
      ssl = true;
      volumes = [
        "caddy:/caddy"
        "${homepage}:/srv/homepage"
        "/persist/home/admin/hidden:/srv/homepage/foo:ro"
        "${pkgs.element-web}:/srv/element"
        "${subsDomain ./element.json}:/srv/element/config.json"
      ];
    };

    ##### exposed services #####

    attic = {
      cmd = [ (getExe pkgs.attic-server) "-f" "${subsDomain ./attic.toml}" ];
      environmentFiles = [ config.aquaris.secrets."machine/attic" ];
      volumes = [ "attic:/data" ];
    };

    avh = {
      cmd = [ (getExe avh) ];
      volumes = [
        "/persist/home/admin/avh/users.db:/users.db"
        "/persist/home/admin/avh/videos:/videos:ro"
      ];
    };

    photoview = {
      cmd = [ (getExe pkgs.photoview) ];
      environment = {
        PHOTOVIEW_DATABASE_DRIVER = "postgres";
        PHOTOVIEW_LISTEN_IP = "0.0.0.0";
        PHOTOVIEW_MEDIA_CACHE = "/data";
      };
      environmentFiles = [ config.aquaris.secrets."machine/photoview" ];
      volumes = [
        "photoview:/data"
        "/persist/home/admin/img:/media:ro"
      ];
    };

    pinlist = {
      cmd = [ (getExe self.inputs.pinlist.packages.${pkgs.system}.default) ];
      environmentFiles = [ config.aquaris.secrets."machine/pinlist" ];
      volumes = [ "pinlist:/db" ];
    };

    searxng = {
      cmd = [ (getExe' pkgs.searxng "searxng-run") ];
      environment = {
        SEARXNG_BIND_ADDRESS = "0.0.0.0";
        SEARXNG_URL = "https://searx.${domain}";
      };
      environmentFiles = [ config.aquaris.secrets."machine/searxng" ];
      ssl = true;
      volumes = [ "${./searxng.yaml}:/etc/searxng/settings.yml" ];
    };

    synapse = {
      cmd = [ (getExe' pkgs.matrix-synapse "synapse_homeserver") "-c" "/config" ];
      ssl = true;
      volumes = [
        "synapse:/data"
        "${subsDomain ./synapse.yaml}:/config/homeserver.yaml"
        "${config.aquaris.secrets."machine/synapse/secrets"}:/config/secrets.yaml"
        "${config.aquaris.secrets."machine/synapse/signing-key"}:/config/signing.key"
      ];
    };

    vaultwarden = {
      cmd = [ (getExe pkgs.vaultwarden) ];
      environment = {
        ROCKET_ADDRESS = "0.0.0.0";
        ROCKET_PORT = "8080";

        DOMAIN = "https://vw.${domain}";
        SIGNUPS_ALLOWED = "false";

        SMTP_FROM = "vault@${domain}";
        SMTP_HOST = "smtp.gmail.com";

        WEB_VAULT_FOLDER = "${pkgs.vaultwarden.webvault}/share/vaultwarden/vault";
      };
      environmentFiles = [ config.aquaris.secrets."machine/vaultwarden" ];
      ssl = true;
      volumes = [ "vaultwarden:/data" ];
    };

    ##### support services #####

    postgres = {
      cmd = [ (getExe' pkgs.postgresql_16 "postgres") "-D" "/data" ];
      volumes = [
        "postgres:/data"
        "postgres:/run/postgresql"
        "${./postgres/postgresql.conf}:/data/postgresql.conf"
        "${./postgres/pg_hba.conf}:/data/pg_hba.conf"
      ];
    };

    redis = {
      cmd = [ (getExe' pkgs.redis "redis-server") "--protected-mode" "no" ];
      volumes = [ "redis:/data" ];
      workdir = "/data";
    };
  };
}
