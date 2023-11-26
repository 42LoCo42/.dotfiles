{ config, lib, ... }:
let
  inherit (lib)
    mkIf
    mkOption
    types;

  inherit (types)
    nullOr
    str;

  id = config.machine-id;
in
{
  options.machine-id = mkOption {
    type = nullOr str;
    default = null;
    description = "The machine ID. Generate one with dbus-uuidgen.";
  };

  config = mkIf (id != null) {
    environment.etc."machine-id".text = id;
    networking.hostId = builtins.substring 0 8 id;
  };
}
