{ self, pkgs, config, lib, aquaris, ... }:
let
  inherit (lib) concatMapStringsSep getExe getExe' pipe splitString;

  domain = "eleonora.gay";

  dn = pipe domain [
    (splitString ".")
    (concatMapStringsSep "," (x: "dc=" + x))
  ];

  subsDomain = file: aquaris.lib.subsF {
    inherit file;
    func = pkgs.writeText;
    subs = { inherit domain dn; };
  };

  chronometer = self.inputs.chronometer.packages.${pkgs.system}.default;

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

  avh = self.inputs.avh.packages.${pkgs.system}.default;

  invfork = pkgs.runCommandCC "invfork"
    { nativeBuildInputs = with pkgs; [ musl ]; } ''
    cc -Wall -Wextra -Werror -O3 -static -flto ${./invfork.c} -o $out
    strip -s $out
  '';
in
{
  imports = [ "${self}/rice/pnoc.nix" ];

  nixpkgs.overlays = [
    (_: _: {
      inherit (self.inputs.obscura.packages.${pkgs.system}) photoview pug;
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
      "machine/rustdesk".user = "rustdesk";
      "machine/synapse/secrets".user = "synapse";
      "machine/synapse/signing-key".user = "synapse";
      "machine/tailscaled".user = "tailscaled";
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

    extraDependencies = with pkgs; [ avh homepage photoview pug ];
  };

  networking = {
    firewall = {
      allowedTCPPorts = [
        # caddy
        80
        443

        # rustdesk
        21115
        21116
        21117
        21118
        21119

        22000 # syncthing
      ];
      allowedUDPPorts = [
        443 # caddy (QUIC)
        21116 # rustdesk
        22000 # syncthing
      ];
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

  systemd.services."mount-dcim" = {
    script = ''
      mkdir -p /home/admin/DCIM
      exec ${pkgs.bindfs}/bin/bindfs \
        -u admin -g users -f         \
        --create-for-user=syncthing  \
        --create-for-group=syncthing \
        /persist/sync/DCIM /home/admin/DCIM
    '';
    wantedBy = [ "default.target" ];
  };

  environment.systemPackages = [
    (pkgs.writeShellApplication {
      name = "normalize";
      runtimeInputs = with pkgs; [ exiftool parallel ];
      text = builtins.readFile ./normalize.sh;
    })
  ];

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
        "${chronometer}:/srv/chronometer"
        "/persist/home/admin/hidden:/srv/homepage/foo:ro"
        "${pkgs.element-web}:/srv/element"
        "${subsDomain ./element.json}:/srv/element/config.json"
      ];
    };

    ##### exposed services #####

    attic = {
      cmd = [ (getExe pkgs.attic-server) ];
      environmentFiles = [ config.aquaris.secrets."machine/attic" ];
      volumes = [
        "attic:/data"
        "${subsDomain ./attic.toml}:/.config/attic/server.toml:ro"
      ];
    };

    avh = {
      cmd = [ (getExe avh) ];
      volumes = [
        "/persist/home/admin/avh/videos:/videos:ro"
      ];
    };

    headscale = {
      cmd = [ (getExe' pkgs.headscale "headscale") "serve" ];
      ssl = true;
      volumes = [
        "headscale:/data"
        "${subsDomain ./headscale.yaml}:/etc/headscale/config.yaml:ro"
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
      volumes = [ "pinlist:/db" ];
    };

    rustdesk =
      let
        pubkey = "Dh0lsYDLdL7GIb0BHWR2VS0mRCLSmyKIJHdtkzmWjdQ=";
        app = pkgs.writeShellApplication {
          name = "rustdesk";
          text = aquaris.lib.subsT ./rustdesk.sh { inherit pubkey; };
          runtimeInputs = with pkgs; [ rustdesk-server ];
        };
      in
      {
        cmd = [ (getExe app) ];
        ports = [
          "21115:21115"
          "21116:21116"
          "21116:21116/udp"
          "21117:21117"
          "21118:21118"
          "21119:21119"
        ];
        volumes = [
          "rustdesk:/data"
          "${config.aquaris.secrets."machine/rustdesk"}:/data/id_ed25519:ro"
        ];
        workdir = "/data";
      };

    searxng = {
      cmd = [ (getExe' pkgs.searxng "searxng-run") ];
      environment = {
        SEARXNG_BIND_ADDRESS = "0.0.0.0";
        SEARXNG_URL = "https://searx.${domain}";
      };
      environmentFiles = [ config.aquaris.secrets."machine/searxng" ];
      ssl = true;
      volumes = [ "${./searxng.yaml}:/etc/searxng/settings.yml:ro" ];
    };

    synapse = {
      cmd = [ (getExe' pkgs.matrix-synapse "synapse_homeserver") "-c" "/config" ];
      ssl = true;
      volumes = [
        "synapse:/data"
        "${subsDomain ./synapse.yaml}:/config/homeserver.yaml:ro"
        "${config.aquaris.secrets."machine/synapse/secrets"}:/config/secrets.yaml:ro"
        "${config.aquaris.secrets."machine/synapse/signing-key"}:/config/signing.key:ro"
      ];
    };

    syncthing = {
      cmd = [ (getExe pkgs.syncthing) "--home=/data" "--gui-address=http://0.0.0.0:8080" ];
      environment.HOME = "/sync";
      ports = [
        "22000:22000"
        "22000:22000/udp"
      ];
      ssl = true;
      volumes = [
        "syncthing:/data"
        "/persist/sync:/sync"
      ];
    };

    tailscaled = {
      cmd = [
        invfork.outPath

        # parent process: tailscaled in declarative mode
        (getExe' pkgs.tailscale "tailscaled")
        "-config=${subsDomain ./tailscaled.json}"
        "-socket=/data/tailscaled.sock"
        "-state=/data/tailscaled.state"
        "-statedir=/data"

        "--" # child process: SSH forwarder
        "${getExe pkgs.socat}"
        "TCP-LISTEN:22,fork,reuseaddr"
        "TCP-CONNECT:host.containers.internal:18213"
      ];
      extraOptions = [
        "--cap-add=net_admin,net_bind_service"
        "--device=/dev/net/tun"
      ];
      ssl = true;
      volumes = [
        "tailscaled:/data"
        "${config.aquaris.secrets."machine/tailscaled"}:/key:ro"
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

    vencloud = {
      cmd = [ (getExe self.inputs.obscura.packages.${pkgs.system}.vencloud) ];
      environment = {
        HOST = "0.0.0.0";
        PORT = "8080";
        REDIS_URI = "redis:6379";

        ROOT_REDIRECT = "https://github.com/Vencord/Vencloud";

        DISCORD_REDIRECT_URI = "https://vencloud.${domain}/v1/oauth/callback";

        SIZE_LIMIT = "32000000";

        PROXY_HEADER = "X-Forwarded-For";
      };
      environmentFiles = [ config.aquaris.secrets."machine/vencloud" ];
      ssl = true;
    };

    ##### support services #####

    authelia = {
      cmd = [ (getExe pkgs.authelia) "-c" "${subsDomain ./authelia.yaml}" ];
      environmentFiles = [ config.aquaris.secrets."machine/authelia" ];
      ssl = true;
      volumes = [ "authelia:/data" ];
    };

    lldap = {
      cmd = [ (getExe pkgs.lldap) "run" ];
      environment = {
        LLDAP_LDAP_BASE_DN = dn;

        LLDAP_HTTP_PORT = "8080";
        LLDAP_HTTP_URL = "https://ldap.${domain}";

        LLDAP_SMTP_OPTIONS__ENABLE_PASSWORD_RESET = "true";
        LLDAP_SMTP_OPTIONS__FROM = "ldap@${domain}";
        LLDAP_SMTP_OPTIONS__SERVER = "smtp.gmail.com";
        LLDAP_SMTP_OPTIONS__PORT = "587";
        LLDAP_SMTP_OPTIONS__SMTP_ENCRYPTION = "STARTTLS";
      };
      environmentFiles = [ config.aquaris.secrets."machine/lldap" ];
      ssl = true;
    };

    postgres = {
      cmd = [ (getExe' pkgs.postgresql_16 "postgres") "-D" "/data" ];
      volumes = [
        "postgres:/data"
        "postgres:/run/postgresql"
        "${./postgres/postgresql.conf}:/data/postgresql.conf:ro"
        "${./postgres/pg_hba.conf}:/data/pg_hba.conf:ro"
      ];
    };

    redis = {
      cmd = [ (getExe' pkgs.redis "redis-server") "--protected-mode" "no" ];
      volumes = [ "redis:/data" ];
      workdir = "/data";
    };
  };
}
