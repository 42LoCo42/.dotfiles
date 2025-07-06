{
  imports = [ ../../rice ];

  aquaris = {
    filesystems = { fs, ... }: {
      zpools.rpool = fs.defaultPool;
    };

    persist.enable = true;
  };

  system.tools = {
    nixos-build-vms.enable = false; # haven't really found a usecase yet
    nixos-enter.enable = false; # doesn't generally work with Aquaris
    nixos-generate-config.enable = true; # might be useful
    nixos-install.enable = false; # Aquaris has custom installer
    nixos-option.enable = false; # https://mynixos.com
    nixos-rebuild.enable = false; # Aquaris has custom `sys` script
    nixos-version.enable = true; # useful; supported by Aquaris
  };

  documentation = {
    info.enable = false;
    nixos.enable = false;
  };
}
