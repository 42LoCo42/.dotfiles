{ pkgs, lib, config, ... }: {
  options.rice.desktop.libvirt.enable = lib.mkOption {
    type = lib.types.bool;
    default = false;
  };

  config = lib.mkIf config.rice.desktop.libvirt.enable {
    networking.firewall.trustedInterfaces = [ "virbr0" ];

    virtualisation.libvirtd = {
      enable = true;

      # libvirt 11.0.0 - fixes virt-manager crash on VM creation
      # TODO wait for https://nixpk.gs/pr-tracker.html?pr=375888
      # hydra build https://hydra.nixos.org/build/291274205
      package = (builtins.getFlake "github:nixos/nixpkgs/8b24638d4d411cb0a8e2df082a212e4c5d5e5f98").legacyPackages.${pkgs.system}.libvirt;

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
        aquaris.persist = { ".config/dconf" = { }; };
      })
    ];
  };
}
