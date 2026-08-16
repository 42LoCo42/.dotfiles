{ config, lib, pkgs, ... }: {
  options.rice.desktop.libvirt.enable = lib.mkOption {
    type = lib.types.bool;
    default = false;
  };

  config = lib.mkIf config.rice.desktop.libvirt.enable {
    networking.firewall.trustedInterfaces = [ "virbr0" ];

    virtualisation.libvirtd = {
      enable = true;

      qemu = {
        package = pkgs.qemu_kvm;
        swtpm.enable = true;
        vhostUserPackages = with pkgs; [ virtiofsd ];
      };
    };

    users.users = builtins.mapAttrs
      (_: _: { extraGroups = [ "libvirtd" ]; })
      config.aquaris.users;

    home-manager.sharedModules = lib.singleton (hm: {
      aquaris = {
        # virt-manager stores stuff in dconf
        persist = { ".config/dconf" = { }; };

        hyprland.binds = f: with f; {
          v = exec "virt-manager";
        };
      };

      home = {
        packages = with pkgs; [
          virt-manager
        ];

        # don't create $HOME/.icons
        file = {
          ".icons/${hm.config.home.pointerCursor.name}".enable = false;
          ".icons/default/index.theme".enable = false;
        };
      };
    });
  };
}
