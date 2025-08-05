{
  fileSystems."/proc" = {
    device = "proc";
    fsType = "proc";
    options = [ "nosuid" "hidepid=invisible" "gid=1" ]; # GID 1 is wheel
  };
}
