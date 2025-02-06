{ pkgs, lib, config, ... }: {
  virtualisation.pnoc.synapse = {
    cmd = [ (lib.getExe' pkgs.matrix-synapse "synapse_homeserver") "-c" "/config" ];

    secrets = [
      "machine/synapse/secrets:/config/secrets.yaml"
      "machine/synapse/signing-key:/config/signing.key"
    ];

    volumes = [
      "synapse:/data"
      "${config.rice.subsDomain ./config.yaml}:/config/homeserver.yaml:ro"
    ];
  };
}
