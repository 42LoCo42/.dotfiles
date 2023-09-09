{ ... }: {
  security.pam = {
    u2f.cue = true;
    services.sudo.u2fAuth = true;
  };
}
