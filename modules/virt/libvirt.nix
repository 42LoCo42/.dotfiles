{ ... }: {
  virtualisation.libvirtd = {
    enable = true;
    qemu.swtpm.enable = true;
  };

  users.users.leonsch.extraGroups = [ "libvirtd" ];
  home-manager.users.leonsch = { pkgs, ... }: {
    home.packages = with pkgs; [
      virt-manager
    ];
  };
}
