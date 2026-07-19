{ config, lib, pkgs, ... }: {
  topology.self.services.msmtpd = {
    name = "msmtp daemon";
    icon = "misc.mail";
    info = "Sending mails from ${config.rice.domain}";
  };

  virtualisation.pnoc.msmtpd = {
    path = with pkgs; [
      envsubst
      msmtp
    ];

    script = ''
      umask 0077
      envsubst < ${./config.txt} > /tmp/config

      # shellcheck disable=SC2016
      exec msmtpd                           \
        --interface 0.0.0.0                 \
        --port      2525                    \
        --log       /dev/stdout             \
        --auth      'user,echo $LOCAL_PASS' \
        --command   'msmtp -C /tmp/config -f %F --'
    '';

    environmentFiles = [ (config.aquaris.secret "@machine/msmtpd") ];

    volumes = [
      # msmtpd runs commands with /bin/sh
      "${lib.getExe pkgs.bash}:/bin/sh:ro"
    ];
  };
}
