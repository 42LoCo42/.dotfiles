{ self, pkgs, lib, config, ... }:
let
  inherit (lib)
    concatStringsSep
    filterAttrs
    init
    mapAttrs
    mapAttrs'
    nameValuePair
    splitString
    ;

  inherit (config.lib.topology) mkInternet;
  inherit (self.inputs) nix-topology;

  removeExtension = filename: concatStringsSep "." (init (splitString "." filename));

  iconsFromFiles = dir:
    mapAttrs' (file: _: nameValuePair (removeExtension file) { file = dir + "/${file}"; }) (
      filterAttrs (_: type: type == "regular") (builtins.readDir dir)
    );
in
{
  imports = [ nix-topology.nixosModules.default ];
  nixpkgs.overlays = [ nix-topology.overlays.default ];

  # protect these from garbage collection
  system.extraDependencies = with pkgs; [
    elk-to-svg
    html-to-svg
  ];

  system.build.topology = (import nix-topology {
    inherit pkgs;
    modules = [{
      nixosConfigurations = builtins.removeAttrs
        self.nixosConfigurations [ "guanyin" ];

      icons = mapAttrs (n: _: iconsFromFiles ./icons/${n})
        (filterAttrs (_: v: v == "directory") (builtins.readDir ./icons));

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
