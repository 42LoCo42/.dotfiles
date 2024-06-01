{ pkgs, config, ... }:
let
  inherit (pkgs.lib)
    fileContents
    getExe
    mapAttrsToList
    pipe
    recursiveUpdate
    splitString
    ;

  mergeAttrList = builtins.foldl' recursiveUpdate { };
in
{
  aquaris = {
    filesystem = { filesystem, zpool, ... }: {
      disks."/dev/disk/by-id/virtio-root". partitions = [
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

      zpools. rpool. datasets = {
        "nixos/nix" = { };
        "nixos/persist" = { };
      };
    };
  };

  users = pipe config.virtualisation.oci-containers.containers [
    builtins.attrNames
    (map (x: {
      users.${x} = {
        group = x;
        isSystemUser = true;
      };
      groups.${x} = { };
    }))
    mergeAttrList
  ];

  virtualisation.containerd.enable = true;

  # virtualisation.podman = {
  #   enable = true;
  #   defaultNetwork.settings.dns_enabled = true;
  # };

  # virtualisation.oci-containers.containers =
  #   let
  #     empty = pkgs.dockerTools.buildImage {
  #       name = "empty";
  #       tag = "latest";
  #     };

  #     pnoc = cfg: pipe cfg [
  #       (x: [ x.entrypoint or "" ] ++ (x.cmd or [ ]))
  #       builtins.toString
  #       (pkgs.writeText "deps")
  #       (x: pipe x [
  #         pkgs.writeClosure
  #         fileContents
  #         (splitString "\n")
  #         (builtins.filter (y: toString x != y))
  #       ])
  #       (map (x: "${x}:${x}"))
  #       (x: cfg // {
  #         image = "${empty.imageName}:${empty.imageTag}";
  #         imageFile = empty;
  #         volumes = (cfg.volumes or [ ]) ++ x;
  #       })
  #     ];
  #   in
  #   {
  #     caddy = pnoc {
  #       user = "${config.users.users.caddy.name}";
  #       extraOptions = [ "--passwd" ];

  #       cmd = [ (getExe pkgs.caddy) "run" "-a" "caddyfile" "-c" "${./Caddyfile}" ];
  #       ports = [
  #         "80:80"
  #         "443:443"
  #       ];
  #       environment.XDG_DATA_HOME = "/";
  #       volumes = [ "caddy:/caddy" ];
  #     };
  #   };

  _module.args.foo = rec {
    pg2 = pkgs.dockerTools.pullImage {
      imageName = "docker.io/bpatrik/pigallery2";
      imageDigest = "sha256:415fc67141fb1e4b30e81eb77f78decaf1e7524dbf87e6b039e1bdf045d71797";
      sha256 = "sha256-Ls6gJA1sgKKQ59HBUPgKZbmbBAY9tSady+gwnlZRGVI=";
    };

    extractImage = img: pkgs.stdenv.mkDerivation {
      name = "extract-${img.imageName}:${img.imageTag}";
      src = img;
      sourceRoot = ".";
      nativeBuildInputs = with pkgs; [ jq ];
      installPhase = ''
        mkdir $out
        jq -r '.[].Layers[]' < manifest.json \
        | xargs -I% tar xf % -C $out
      '';
      dontFixup = true;
    };

    getDeps = data: pipe data [
      builtins.toJSON
      (pkgs.writeText "deps")
      (x: pipe x [
        pkgs.writeClosure
        fileContents
        (splitString "\n")
        (builtins.filter (y: toString x != y))
      ])
    ];

    args = [ (getExe pkgs.python3) "-m" "http.server" ];

    buildOCI = cmd:
      let
        sysMounts = {
          "/proc" = {
            type = "proc";
            source = "proc";
          };
          "/dev" = {
            type = "tmpfs";
            source = "tmpfs";
            options = [ "nosuid" "strictatime" "mode=755" "size=65536k" ];
          };
          "/dev/pts" = {
            type = "devpts";
            source = "devpts";
            options = [ "nosuid" "noexec" "newinstance" "ptmxmode=0666" "mode=755" "gid=5" ];
          };
          "/dev/shm" = {
            type = "tmpfs";
            source = "shm";
            options = [ "nosuid" "noexec" "nodev" "mode=1777" "size=65536k" ];
          };
          "/dev/mqueue" = {
            type = "mqueue";
            source = "mqueue";
            options = [ "nosuid" "noexec" "nodev" ];
          };
          "/sys" = {
            type = "sysfs";
            source = "sysfs";
            options = [ "nosuid" "noexec" "nodev" "ro" ];
          };
          "/sys/fs/cgroup" = {
            type = "cgroup";
            source = "cgroup";
            options = [ "nosuid" "noexec" "nodev" "relatime" "ro" ];
          };
          "/etc/hosts" = {
            type = "none";
            source = pkgs.writeText "hosts" ''
              127.0.0.1 localhost foo
            '';
            options = [ "bind" ];
          };
          "/etc/resolv.conf" = {
            type = "none";
            source = pkgs.writeText "resolv.conf" ''
              search dns.podman
              nameserver 10.0.0.1
            '';
            options = [ "bind" ];
          };
        };

        cmdMounts = pipe
          (with pkgs; [
            cmd
            util-linux
            iputils
            nmap
            dig
          ]) [
          getDeps
          (map (path: {
            name = builtins.unsafeDiscardStringContext path;
            value = { type = "none"; source = path; options = [ "bind" ]; };
          }))
          builtins.listToAttrs
        ];

        mkMounts = mapAttrsToList
          (destination: { type, source, options ? null }: {
            inherit destination type source options;
          });

        config = pkgs.writeText "config.json" (builtins.toJSON {
          ociVersion = "1.0.0";

          platform = { os = "Linux"; arch = "x86_64"; };

          hostname = "foo";

          linux.namespaces = map (type: { inherit type; })
            [ "pid" "mount" "ipc" "uts" ] ++
          [{ type = "network"; path = "/run/netns/1337"; }];

          root = { path = "/tmp/rootfs"; readonly = true; };

          process = {
            args = cmd;
            user = { uid = 65534; gid = 65534; };
            cwd = "/";
          };

          mounts = mkMounts sysMounts ++ mkMounts cmdMounts;
        });
      in
      pkgs.runCommand "oci" { } ''
        install -Dm444 ${config} $out/config.json
      '';

    oci = buildOCI args;
  };
}
