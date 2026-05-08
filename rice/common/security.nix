{ lib, ... }:
let
  inherit (lib)
    mkForce
    mkMerge
    pipe
    ;
in
{
  fileSystems."/proc" = {
    device = "proc";
    fsType = "proc";
    options = [ "nosuid" "hidepid=invisible" "gid=1" ]; # GID 1 is wheel
  };

  security.wrappers = pipe [
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
    (map (x: { ${x}.enable = mkForce false; }))
    mkMerge
  ];
}
