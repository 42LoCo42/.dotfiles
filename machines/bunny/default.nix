{ pkgs, config, lib, my-utils, ... }: {
  fileSystems."/" = {
    fsType = "tmpfs";
    options = [ "mode=755" ];
  };

  aquaris = {
    filesystem = { filesystem, zpool, ... }: {
      # TODO real disk id: scsi-36024c6ac39264da98ce1a64b9fab7a20
      disks."/dev/disk/by-id/virtio-root".partitions = [
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

      zpools.rpool.datasets =
        { "nixos/nix" = { }; } //
        (lib.mapAttrs'
          (_: user: {
            name = "nixos${config.aquaris.persist.root}/home/${user.name}";
            value = { };
          })
          config.aquaris.users);
    };

    secrets = {
      "machine/synapse-secrets".user = "nobody";
      "machine/synapse-signing-key".user = "nobody";
    };
  };

  boot.lanzaboote.enable = lib.mkForce false;
  boot.loader.systemd-boot.enable = lib.mkOverride 0 true;

  users.users.admin.openssh.authorizedKeys.keys =
    [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJVieLCkWGImVI9c7D0Z0qRxBAKf0eaQWUfMn0uyM/Ql" ];

  networking.firewall.allowedTCPPorts = [ 80 443 ];
  networking.firewall.allowedUDPPorts = [ 443 ];

  virtualisation.podman.defaultNetwork.settings.dns_enabled = true;

  virtualisation.oci-containers.containers =
    let
      domain = "42loco42.duckdns.org";
      subsDomain = file: my-utils.subsF {
        inherit file;
        func = pkgs.writeText;
        subs = { inherit domain; };
      };

      select = amd64: arm64:
        if pkgs.system == "x86_64-linux" then amd64
        else if pkgs.system == "aarch64-linux" then arm64
        else abort "pkgs.system: ${pkgs.system}: invalid!";

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
            runtimeInputs = with pkgs; [
              coreutils
            ];
            text = lib.pipe volumes [
              (map (v: "chown ${user} /vol/${v}"))
              (s: [ "set -x" ] ++ s ++ [ "sleep inf" ])
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
    in
    {
      volume-setup = mkVolumeSetup [
        "caddy_data"
        "synapse_data"
      ];

      caddy = {
        inherit user;
        image = select
          "caddy@sha256:67d0aa24ce021bee77049ddd2c0cc64732dd43d04598085ec39f950a13981bd0"
          "caddy@sha256:2ec95d40ce2d1f18f92eee012a5dd18b352075d92eb6c4f4e0ea18c46ad4b069";
        ports = [
          "80:8000"
          "443:4430"
        ];
        volumes = [
          "caddy_data:/data"
          "${./Caddyfile}:/etc/caddy/Caddyfile"
          "${pkgs.element-web}:/srv/element"
          "${subsDomain ./element.json}:/srv/element/config.json"
        ];
        environment.DOMAIN = domain;
      };

      redis = {
        inherit user;
        image = select
          "redis@sha256:fe98b2d39d462d06a7360e2860dd6ceff930745e3731eccb3c1406dd0dd7f744"
          "redis@sha256:197c38d14b42b59a49ed7d76adf85b93f8c18c1631031841ad26c81c5e11f96e";
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
          image = select
            "searxng/searxng@sha256:5e4afc01591e1208ad3b74a29ce65802f78d3bf92cddcfbdd9427ce690e935f6"
            "searxng/searxng@sha256:29dcad2e76a4ab3e87129755df4b3ca6d1ff72b1eca6320d23056ac184afd8a4";
          volumes = [
            "${./searxng.yaml}:/etc/searxng/settings.yml"
            "${su-exec}:/sbin/su-exec"
          ];
          environmentFiles = [ config.aquaris.secrets."machine/searxng" ];
          environment.SEARXNG_BASE_URL = "https://searx.${domain}";
        };

      synapse = {
        inherit user;
        image = select
          "matrixdotorg/synapse@sha256:f8de2fc05de8a15e46ce152a2708e00be3b1fe25f68fbf596a108a5c236bb3f6"
          "matrixdotorg/synapse@sha256:8816e729ef77fc3f79f39e6c38ffc73388059c0eac3c34a13b0d11f6d61ab64a";
        volumes = [
          "synapse_data:/data"
          "${subsDomain ./synapse.yaml}:/config/homeserver.yaml"
          "${config.aquaris.secrets."machine/synapse-secrets"}:/config/secrets.yaml"
          "${config.aquaris.secrets."machine/synapse-signing-key"}:/config/signing.key"
        ];
        cmd = [ "run" "-c" "/config" ];
      };
    };
}
