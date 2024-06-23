{ self, pkgs, config, lib, my-utils, ... }:
let
  inherit (lib) getExe getExe' pipe;

  domain = "eleonora.gay";
  subsDomain = file: my-utils.subsF {
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
in
{
  nixpkgs.overlays = [ self.inputs.obscura.overlay ];

  aquaris = {
    filesystem = { filesystem, zpool, ... }: {
      disks."/dev/disk/by-id/scsi-36024c6ac39264da98ce1a64b9fab7a20".partitions = [
        {
          type = "uefi";
          size = "512M";
          content = filesystem {
            type = "vfat";
            mountpoint = "/boot";
          };
        }
        { content = zpool (p: p.rpool); }
      ];

      zpools.rpool.datasets = {
        "nixos/nix" = { };
        "nixos/persist".options."com.sun:auto-snapshot" = "true";
        "nixos/persist/home/admin" = { };
        "nixos/persist/home/coder" = { };
      };
    };

    secrets = {
      "machine/synapse/secrets".user = "synapse";
      "machine/synapse/signing-key".user = "synapse";
    };

    persist = {
      system = [
        "/var/lib/containers"
        "/var/lib/nixos"
      ];
      users.admin = [
        "hidden"
        "img"
      ];
    };
  };

  boot.lanzaboote.enable = lib.mkForce false;
  boot.loader.systemd-boot.enable = lib.mkOverride 0 true;

  system.autoUpgrade = {
    enable = true;
    flake = "github:42loco42/.dotfiles";
    flags = [ "--refresh" "-L" ];
  };

  nix.gc.automatic = true;
  system.activationScripts.gc-generations.text = ''
    ${pkgs.nix}/bin/nix-env                  \
      --profile /nix/var/nix/profiles/system \
      --delete-generations +5
  '';

  system.extraDependencies = with pkgs; [ photoview pug ];

  networking.firewall.allowedTCPPorts = [ 80 443 ];
  networking.firewall.allowedUDPPorts = [ 443 ];
  networking.networkmanager.enable = lib.mkForce false;

  services.openssh.ports = lib.mkForce [ 18213 ];

  services.zfs = {
    autoScrub = { enable = true; interval = "weekly"; };
    autoSnapshot.enable = true;
    trim.enable = true;
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
      cmd = [ (getExe self.inputs.avh.packages.${pkgs.system}.default) ];
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
