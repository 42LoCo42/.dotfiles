{ pkgs, lib, config, ... }: lib.mkIf config.rice.desktop {
  networking.firewall.trustedInterfaces = [ "virbr0" ];

  virtualisation.libvirtd = {
    enable = true;
    qemu = {
      ovmf.packages = with pkgs; [ OVMFFull.fd ];
      swtpm.enable = true;
    };
  };

  users.users = builtins.mapAttrs
    (_: _: { extraGroups = [ "libvirtd" ]; })
    config.aquaris.users;

  home-manager.sharedModules = [{
    home = {
      packages = with pkgs; [
        virt-manager
      ];

      # a cursor theme is required for virt-manager
      pointerCursor = {
        name = "Vanilla-DMZ";
        size = 24;
        package = pkgs.vanilla-dmz;
        gtk.enable = true;
      };
    };

    # virt-manager stores stuff in dconf
    aquaris.persist = [ ".config/dconf" ];
  }];
}
