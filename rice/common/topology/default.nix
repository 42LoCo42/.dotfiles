{ self, pkgs, lib, config, ... }:
let
  inherit (lib)
    concatStringsSep
    filterAttrs
    init
    mapAttrs
    mapAttrs'
    mkForce
    nameValuePair
    pipe
    splitString
    ;

  inherit (config.lib.topology) mkInternet;
  inherit (self.inputs) nix-topology;

  removeExtension = filename: concatStringsSep "." (init (splitString "." filename));

  iconsFromFiles = dir: pipe dir [
    builtins.readDir
    (filterAttrs (_: t: t == "regular"))
    (mapAttrs' (file: _: nameValuePair
      (removeExtension file)
      { file = mkForce "${dir}/${file}"; }))
  ];
in
{
  imports = [ nix-topology.nixosModules.default ];
  nixpkgs.overlays = [ nix-topology.overlays.default ];

  system.build.topology = (import nix-topology {
    inherit pkgs;
    modules = [{
      nixosConfigurations = builtins.removeAttrs
        self.nixosConfigurations [ "guanyin" ];

      icons = pipe ./icons [
        builtins.readDir
        (filterAttrs (_: t: t == "directory"))
        (mapAttrs (n: _: iconsFromFiles ./icons/${n}))
      ];

      renderers.elk.overviews = {
        services.enable = false;
        networks.enable = false;
      };

      nodes = {
        fritzbox = {
          name = "FRITZ!Box 7520";
          hardware.info = "Router";

          deviceIcon = "misc.fritzbox";
          deviceType = "router";

          interfaces = {
            lan = {
              addresses = [ "192.168.178.1" ];
              network = "lan";
            };

            wan = {
              network = "internet";
              physicalConnections = [{
                node = "internet";
                interface = "*";
              }];
            };
          };
        };

        internet = mkInternet { };
      };

      networks = {
        internet = {
          name = "Internet";
        };

        lan = {
          name = "LAN";
          cidrv4 = "192.168.178.0/24";
          cidrv6 = "2003:dc:9720:3d00::/64";
        };

        vpn = {
          name = "Tailscale VPN";
          cidrv4 = "100.64.0.0/10";
          cidrv6 = "fd7a:115c:a1e0::/48";
        };
      };
    }];
  }).config.output;
}
