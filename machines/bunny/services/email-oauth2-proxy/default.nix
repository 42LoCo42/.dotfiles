{ pkgs, lib, config, ... }: {
  virtualisation.pnoc.email-oauth2-proxy = {
    cmd = [
      (lib.getExe (pkgs.writeShellApplication {
        name = "email-oauth2-proxy";
        text = builtins.readFile ./start.sh;
        runtimeInputs = with pkgs; [
          email-oauth2-proxy
          envsubst
        ];
      }))
      "${./emailproxy.config}"
    ];

    environmentFiles = [ (config.aquaris.secret "@machine/email-oauth2-proxy") ];

    extraOptions = [ "--tmpfs=/tmp" ];

    volumes = [ "email-oauth2-proxy:/data" ];
  };
}
