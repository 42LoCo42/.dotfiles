# TODO upstream to Aquaris

{ ... }: {
  security.sudo-rs = {
    enable = true;
    execWheelOnly = true;
  };
}
