{
  fileSystems."/proc" = {
    device = "proc";
    fsType = "proc";
    options = [ "hidepid=invisible" "gid=1" ]; # GID 1 is wheel
  };
}
