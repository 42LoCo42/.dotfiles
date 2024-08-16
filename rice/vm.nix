{ pkgs, ... }: {
  networking.firewall.trustedInterfaces = [ "virbr0" ];

  virtualisation.libvirtd = {
    enable = true;
    qemu = {
      ovmf.packages = with pkgs; [ OVMFFull.fd ];
      swtpm.enable = true;
    };
  };

  users.users.leonsch.extraGroups = [ "libvirtd" ];

  home-manager.sharedModules = [{
    # a cursor theme is required for virt-manager
    home.pointerCursor = {
      name = "Vanilla-DMZ";
      size = 24;
      package = pkgs.vanilla-dmz;
      gtk.enable = true;
    };
  }];
}
