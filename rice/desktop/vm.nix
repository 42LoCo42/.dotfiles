{ pkgs, lib, config, ... }: lib.mkIf config.rice.desktop {
  networking.firewall.trustedInterfaces = [ "virbr0" ];

  virtualisation.libvirtd = {
    enable = true;
    qemu = {
      package = pkgs.qemu_kvm;
      ovmf.packages = with pkgs; [ OVMFFull.fd ];
      swtpm.enable = true;
    };
  };

  users.users = builtins.mapAttrs
    (_: _: { extraGroups = [ "libvirtd" ]; })
    config.aquaris.users;

  home-manager.sharedModules = [
    (hm: {
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

        # don't create $HOME/.icons
        file = {
          ".icons/${hm.config.home.pointerCursor.name}".enable = false;
          ".icons/default/index.theme".enable = false;
        };
      };

      # virt-manager stores stuff in dconf
      aquaris.persist = [ ".config/dconf" ];
    })
  ];
}
