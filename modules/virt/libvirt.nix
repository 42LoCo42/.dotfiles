{ ... }: {
  virtualisation.libvirtd = {
    enable = true;
    qemu.swtpm.enable = true;
  };

  users.users.default.extraGroups = [ "libvirtd" ];
  home-manager.users.default = { pkgs, ... }: {
    home.packages = with pkgs; [
      virt-manager
    ];
  };
}
