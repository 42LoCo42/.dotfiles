{ pkgs, lib, config, ... }: lib.mkIf false {
  aquaris.secrets = {
    "machine:bunny.synapse:secrets".user = "synapse";
    "machine:bunny.synapse:signing-key".user = "synapse";
  };

  virtualisation.pnoc.synapse = {
    cmd = [ (lib.getExe' pkgs.matrix-synapse "synapse_homeserver") "-c" "/config" ];
    volumes = [
      "synapse:/data"
      "${config.rice.subsDomain ./config.yaml}:/config/homeserver.yaml:ro"
      "${config.aquaris.secrets."machine/synapse/secrets"}:/config/secrets.yaml:ro"
      "${config.aquaris.secrets."machine/synapse/signing-key"}:/config/signing.key:ro"
    ];
  };
}
