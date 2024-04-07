{ self, pkgs, config, lib, my-utils, ... }: {
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
      };
    };

    secrets = {
      "machine/synapse/secrets".user = "nobody";
      "machine/synapse/signing-key".user = "nobody";
    };

    persist = {
      system = [
        "/var/lib/containers"
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

  system.extraDependencies = [
    self.inputs.obscura.packages.${pkgs.system}.pug
  ];

  users.users.admin.openssh.authorizedKeys.keys =
    [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJVieLCkWGImVI9c7D0Z0qRxBAKf0eaQWUfMn0uyM/Ql" ];

  boot.kernel.sysctl."net.ipv4.ip_unprivileged_port_start" = 0;
  networking.firewall.allowedTCPPorts = [ 80 443 ];
  networking.firewall.allowedUDPPorts = [ 443 ];
  networking.networkmanager.enable = lib.mkForce false;

  services.openssh.ports = lib.mkForce [ 18213 ];

  services.zfs.autoSnapshot.enable = true;

  systemd.services.podman-volume-setup.serviceConfig.Restart = lib.mkForce "on-failure";
  virtualisation.podman.defaultNetwork.settings.dns_enabled = true;
  virtualisation.oci-containers.containers =
    let
      domain = "eleonora.gay";
      subsDomain = file: my-utils.subsF {
        inherit file;
        func = pkgs.writeText;
        subs = { inherit domain; };
      };

      user = lib.pipe [
        config.users.users.nobody.uid
        config.users.groups.nogroup.gid
      ] [
        (map (x: builtins.toString x))
        (builtins.concatStringsSep ":")
      ];

      mkVolumeSetup = volumes:
        let
          program = pkgs.writeShellApplication {
            name = "volume-setup";
            runtimeInputs = with pkgs; [ coreutils ];
            text = lib.pipe volumes [
              (map (v: "chown ${user} /vol/${v}"))
              (s: [ "set -x" ] ++ s)
              (builtins.concatStringsSep "\n")
            ];
          };

          imageFile = pkgs.dockerTools.buildImage {
            name = "volume-setup";
            tag = "latest";
            config.Cmd = [ (lib.getExe program) ];
          };
        in
        {
          inherit imageFile;
          image = "volume-setup:latest";
          volumes = map (v: "${v}:/vol/${v}") volumes;
        };

      homepage-font = lib.pipe pkgs.nerdfonts [
        (f: f.override { fonts = [ "Iosevka" ]; })
        (f: "${f}/share/fonts/truetype/NerdFonts/IosevkaNerdFont-Regular.ttf")
      ];

      homepage = pkgs.stdenvNoCC.mkDerivation {
        name = "homepage";
        src = let d = ../../homepage; in lib.fileset.toSource {
          root = d;
          fileset = d;
        };

        nativeBuildInputs = with pkgs; [
          glibcLocales
          tree
          self.inputs.obscura.packages.${pkgs.system}.pug
        ];

        buildPhase = ''
          cp -r static $out
          cp "${homepage-font}" $out/iosevka.ttf
          bash processStuff.sh
          pug3 -o $out .
        '';
      };
    in
    {
      volume-setup = mkVolumeSetup [
        "caddy_data"
        "pigallery2_data"
        "pinlist_data"
        "redis_data"
        "synapse_data"
        "vaultwarden_data"
      ];

      caddy = {
        inherit user;
        image = "caddy@sha256:2ec95d40ce2d1f18f92eee012a5dd18b352075d92eb6c4f4e0ea18c46ad4b069";
        ports = [
          "80:80"
          "443:443"
          "443:443/udp"
        ];
        volumes = [
          "caddy_data:/data/caddy"
          "${./Caddyfile}:/etc/caddy/Caddyfile"
          "${homepage}:/srv/homepage"
          "${config.aquaris.persist.root}/home/admin/hidden:/srv/homepage/foo"
          "${pkgs.element-web}:/srv/element"
          "${subsDomain ./element.json}:/srv/element/config.json"
        ];
        environment.DOMAIN = domain;
      };

      pinlist = {
        inherit user;
        image = "pinlist:latest";
        imageFile = self.inputs.pinlist.packages.${pkgs.system}.image;
        volumes = [ "pinlist_data:/db" ];
        environmentFiles = [ config.aquaris.secrets."machine/pinlist" ];
      };

      redis = {
        inherit user;
        image = "redis@sha256:197c38d14b42b59a49ed7d76adf85b93f8c18c1631031841ad26c81c5e11f96e";
        volumes = [ "redis_data:/data" ];
      };

      searxng =
        let
          su-exec = pkgs.writeScript "su-exec" ''
            #!/usr/bin/env sh
            shift # consume user:group
            exec "$@"
          '';
        in
        {
          inherit user;
          image = "searxng/searxng@sha256:29dcad2e76a4ab3e87129755df4b3ca6d1ff72b1eca6320d23056ac184afd8a4";
          extraOptions = [ "--stop-signal=SIGINT" ];
          volumes = [
            "${./searxng.yaml}:/etc/searxng/settings.yml"
            "${su-exec}:/sbin/su-exec"
          ];
          environmentFiles = [ config.aquaris.secrets."machine/searxng" ];
          environment.SEARXNG_BASE_URL = "https://searx.${domain}";
        };

      synapse = {
        inherit user;
        image = "matrixdotorg/synapse@sha256:8816e729ef77fc3f79f39e6c38ffc73388059c0eac3c34a13b0d11f6d61ab64a";
        volumes = [
          "synapse_data:/data"
          "${subsDomain ./synapse.yaml}:/config/homeserver.yaml"
          "${config.aquaris.secrets."machine/synapse/secrets"}:/config/secrets.yaml"
          "${config.aquaris.secrets."machine/synapse/signing-key"}:/config/signing.key"
        ];
        cmd = [ "run" "-c" "/config" ];
      };

      synapse-db = {
        image = "postgres@sha256:354a818d8a1e94707704902edb8c4e98b0eb64de3ee0354c4d94b4e2905c63ee";
        volumes = [ "synapse-db_data:/db" ];
        environment = {
          POSTGRES_INITDB_ARGS = "--encoding=UTF8 --locale=C";
          PGDATA = "/db";
        };
        environmentFiles = [ config.aquaris.secrets."machine/synapse/db-password" ];
      };

      pigallery2 = {
        inherit user;
        image = "bpatrik/pigallery2@sha256:c6a216c36f29de66bfba5f0c2cc855992e1a8e715ca9c6838ea630d2411b5e46";
        extraOptions = [ "--health-cmd=none" ];
        volumes = [
          "${subsDomain ./pigallery2.json}:/app/data/config/config.json"
          "${config.aquaris.persist.root}/home/admin/img:/media"
          "pigallery2_data:/data"
        ];
        environment.NODE_ENV = "production";
      };

      vaultwarden = {
        inherit user;
        image = "vaultwarden/server@sha256:edb8e2bab9cbca22e555638294db9b3657ffbb6e5d149a29d7ccdb243e3c71e0";
        volumes = [ "vaultwarden_data:/data" ];
        environment = {
          DOMAIN = "https://vw.${domain}";
          ROCKET_PORT = "8080";
          SIGNUPS_ALLOWED = "false";

          SMTP_HOST = "smtp.gmail.com";
          SMTP_FROM = "vault@${domain}";
        };
        environmentFiles = [ config.aquaris.secrets."machine/vaultwarden" ];
      };
    };
}
