{
  fileSystems."/proc" = {
    device = "proc";
    fsType = "proc";
    options = [ "hidepid=invisible" "gid=wheel" ];
  };
}
