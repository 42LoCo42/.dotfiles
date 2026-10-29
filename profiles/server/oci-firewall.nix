{ config, lib, pkgs, ... }:
let
  inherit (lib) concat concatMap mkIf mkOption pipe toUpper zipAttrs;
  inherit (lib.types) bool enum listOf port str submodule;

  cfg = config.rice.oci-firewall;

  mkRule = ipv: x: {
    description = "${x.desc} (IPv${toString ipv})";
    protocol = { tcp = 6; udp = 17; }.${x.type};

    source = if ipv == 4 then "0.0.0.0/0" else "::/0";
    source-type = "CIDR_BLOCK";

    "${x.type}-options".destination-port-range = {
      inherit (x) max min;
    };
  };

  rules = pipe cfg.rules [
    (concatMap (x: [
      (mkRule 4 x)
      (mkRule 6 x)
    ]))
    (concat [
      {
        description = "OCI default ICMP (public)";
        protocol = "1";

        source = "0.0.0.0/0";
        source-type = "CIDR_BLOCK";

        icmp-options = {
          code = 4;
          type = 3;
        };
      }

      {
        description = "OCI default ICMP (private)";
        protocol = "1";

        source = "10.0.0.0/16";
        source-type = "CIDR_BLOCK";

        icmp-options = {
          type = 3;
        };
      }
    ])
    (pkgs.writers.writeJSON "oci-firewall.json")
  ];
in
{
  options.rice.oci-firewall = {
    enable = mkOption { type = bool; default = false; };

    auth = {
      fingerprint = mkOption { type = str; };
      keyFile = mkOption { type = str; };
      list = mkOption { type = str; };
      region = mkOption { type = str; };
      tenancy = mkOption { type = str; };
      user = mkOption { type = str; };
    };

    rules = mkOption {
      type = listOf (submodule ({ config, ... }: {
        options = {
          desc = mkOption { type = str; };
          port = mkOption { type = port; };
          type = mkOption { type = enum [ "tcp" "udp" ]; };

          min = mkOption { type = port; default = config.port; };
          max = mkOption { type = port; default = config.port; };
        };
      }));

      default = [ ];
    };
  };

  config = mkIf cfg.enable {
    systemd.services.oci-firewall = {
      after = [ "network-online.target" ];
      wants = [ "network-online.target" ];
      wantedBy = [ "default.target" ];

      environment = with cfg.auth; {
        OCI_CLI_FINGERPRINT = fingerprint;
        OCI_CLI_KEY_FILE = keyFile;
        OCI_CLI_REGION = region;
        OCI_CLI_TENANCY = tenancy;
        OCI_CLI_USER = user;
      };

      path = with pkgs; [ oci-cli ];

      script = ''
        oci network security-list update            \
          --security-list-id ${cfg.auth.list}       \
          --ingress-security-rules file://${rules}  \
          --force
      '';

      serviceConfig.Type = "oneshot";
    };

    networking.firewall = pipe cfg.rules [
      (map (x:
        let name = "allowed${toUpper x.type}Port"; in
        if x.min == x.max then {
          "${name}s" = x.min;
        } else {
          "${name}Ranges" = { from = x.min; to = x.max; };
        }))
      zipAttrs
    ];
  };
}
