{ lib, ... }: {
  fileSystems."/proc" = {
    device = "proc";
    fsType = "proc";
    options = [ "nosuid" "hidepid=invisible" "gid=1" ]; # GID 1 is wheel
  };

  security.wrappers = lib.pipe [
    "Hyprland"
    "fusermount"
    "fusermount3"
    "mount"
    "newgidmap"
    "newgrp"
    "newuidmap"
    "pkexec"
    "sg"
    "su"
    "sudoedit"
    "umount"
  ] [
    (map (x: { ${x}.enable = false; }))
    lib.mkMerge
  ];
}
