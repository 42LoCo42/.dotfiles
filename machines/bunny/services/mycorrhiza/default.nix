{ self, pkgs, lib, config, ... }: {
  virtualisation.pnoc.mycorrhiza = {
    cmd = [ (lib.getExe pkgs.tini) "--" (lib.getExe pkgs.mycorrhiza) "/data" ];
    volumes = [
      "mycorrhiza:/data"
      "${builtins.path { path = "${self}/homepage/static/favicon.ico"; }}:/data/static/favicon.ico:ro"
      "${config.rice.subsDomain ./config.ini}:/data/config.ini:ro"
    ];
  };
}
