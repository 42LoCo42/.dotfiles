{
  services.chrony = {
    enable = true;
    enableNTS = true;
    servers = [
      "ntp3.fau.de"
      "ptbtime1.ptb.de"
      "ptbtime2.ptb.de"
      "ptbtime3.ptb.de"
      "ptbtime4.ptb.de"
      "time.cloudflare.com"
    ];

    extraConfig = ''
      # NTP fallback
      server pool.ntp.org iburst
    '';
  };

  aquaris.persist.dirs = {
    "/var/lib/chrony" = {
      m = "0750";
      u = "chrony";
      g = "chrony";
    };
  };
}
