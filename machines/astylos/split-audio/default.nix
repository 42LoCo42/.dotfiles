{ pkgs, ... }: {
  boot.extraModprobeConfig = ''
    options snd-hda-intel patch=split-audio
  '';

  hardware = {
    firmware = [
      (pkgs.writeTextDir "lib/firmware/split-audio"
        (builtins.readFile ./patch.conf))
    ];

    alsa.enablePersistence = true;
  };

  services.udev.extraRules = ''
    SUBSYSTEMS=="pci", ATTRS{vendor}=="0x8086", ATTRS{device}=="0xa170", \
    ENV{ACP_PROFILE_SET}="${./profile.conf}"
  '';

  aquaris.persist.dirs = {
    "/var/lib/alsa" = { };
  };

  environment.systemPackages = with pkgs; [ alsa-utils ];
}
