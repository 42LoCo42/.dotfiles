{ pkgs, lib, config, ... }: lib.mkIf false {
  aquaris.secrets.rules = {
    "machine/synapse:secrets".user = "synapse";
    "machine/synapse:signing-key".user = "synapse";
  };

  virtualisation.pnoc.synapse = {
    cmd = [ (lib.getExe' pkgs.matrix-synapse "synapse_homeserver") "-c" "/config" ];
    volumes = [
      "synapse:/data"
      "${config.rice.subsDomain ./config.yaml}:/config/homeserver.yaml:ro"
      "${config.aquaris.secret "machine/synapse/secrets"}:/config/secrets.yaml:ro"
      "${config.aquaris.secret "machine/synapse/signing-key"}:/config/signing.key:ro"
    ];
  };
}
