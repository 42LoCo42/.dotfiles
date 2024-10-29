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
  };

  aquaris.persist.dirs = [
    { d = "/var/lib/chrony"; u = "chrony"; g = "chrony"; m = "0750"; }
  ];
}
