{ pkgs, lib, config, aquaris, ... }: {
  imports = [ ../common ./options.nix ];

  nixpkgs.overlays = [
    (_: pkgs: {
      tscaddy = pkgs.caddy.withPlugins {
        plugins = [
          "github.com/tailscale/caddy-tailscale@v0.0.0-20250207163903-69a970c84556"
        ];

        hash = "sha256-TS5Ym3jHa2H2fmwV/QYoZRk7yEE+UWIcyabhhRQQrUM=";
      };
    })
  ];

  aquaris = {
    users = pkgs.lib.mkMerge [
      { inherit (aquaris.cfg.users) admin; }
      { admin.admin = true; }
    ];
  };

  system.autoUpgrade = {
    enable = true;
    flake = "github:42loco42/.dotfiles";
    flags = [ "--refresh" "-L" ];
  };

  systemd.services.nixos-upgrade.script =
    let keep = config.aquaris.machine.keepGenerations; in
    lib.mkIf (keep != null) (lib.mkAfter ''
      nix-env \
        --profile /nix/var/nix/profiles/system \
        --delete-generations "+${toString keep}"
    '');

  nix.gc.automatic = true;

  rice = {
    pam-rssh.enable = true;
    podman.enable = true;
  };
}
