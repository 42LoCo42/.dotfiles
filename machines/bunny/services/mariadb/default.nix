{ pkgs, lib, ... }: {
  virtualisation.pnoc.mariadb = {
    cmd = [
      (lib.getExe ((pkgs.writeShellApplication {
        name = "mariadb";
        text = builtins.readFile ./run.sh;
        runtimeInputs = with pkgs; [
          coreutils
          gnused
          mariadb
        ];
      }).overrideAttrs (old: {
        buildCommand = old.buildCommand + ''
          ln -s ${lib.getExe' pkgs.mariadb "mysql"}    $out/bin/
          ln -s ${lib.getExe' pkgs.mariadb "mariadbd"} $out/bin/
        '';
      })))
    ];
    extraOptions = [ "--tmpfs=/tmp" ];
    volumes = [ "mariadb:/data" ];
  };
}
