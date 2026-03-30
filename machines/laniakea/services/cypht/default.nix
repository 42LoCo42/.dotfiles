{ pkgs, lib, config, aquaris, ... }:
let
  modules = lib.join "," [
    "2fa"
    "account"
    "advanced_search"
    "calendar"
    "contacts"
    "local_contacts"
    "core"
    "desktop_notifications"
    "developer"
    "feeds"
    "history"
    "imap"
    "imap_folders"
    "keyboard_shortcuts"
    "nux"
    "profiles"
    "saved_searches"
    "sievefilters"
    "smtp"
    "tags"
    "themes"
  ];

  cfg = aquaris.lib.subsF {
    file = ./cypht.conf;
    func = pkgs.writeText;
    subs = { inherit modules; };
  };

  php' = pkgs.php.withExtensions (e: e.enabled ++ (with e.all; [
    redis
  ]));
in
{
  nixpkgs.overlays = [
    (_: prev: {
      # TODO upstream to obscura
      cypht = php'.buildComposerProject2 (drv: {
        pname = "cypht";
        version = "2.7.0";

        src = prev.fetchFromGitHub {
          owner = "cypht-org";
          repo = drv.pname;
          tag = "v${drv.version}";
          hash = "sha256-2U9l+s2aw4tgGEpVHBxcPw5HP77NEdZ1hpTFWdv3WOs=";
        };

        composerStrictValidation = false;
        vendorHash = "sha256-HC4ETiQs8sL9JGXJzQafel2uzDVwFMjcsyupiowtrD0=";

        postBuild = ''
          cat << EOF > lib/version.php
          <?php define('CYPHT_VERSION', '${drv.version}'); ?>
          EOF
        '';

        postInstall = ''
          ln -sfv ${cfg} $out/share/php/${drv.pname}/.env
          php $out/share/php/${drv.pname}/scripts/config_gen.php
          ln -sfv /tmp/cypht.conf $out/share/php/${drv.pname}/.env
        '';
      });
    })
  ];

  virtualisation.pnoc.cypht = {
    path = with pkgs; [
      coreutils
      envsubst
      php'
      valkey
    ];

    script = ''
      envsubst < ${cfg} > /tmp/cypht.conf

      mkdir -p /data/attachments
      php /srv/cypht/scripts/setup_database.php

      exec ${config.rice.invfork} \
        redis-server              \
          --dir /data             \
          --bind 127.0.0.1        \
        -- php-fpm -F -y ${./php-fpm.conf}
    '';

    environmentFiles = [ (config.aquaris.secret "@machine/cypht") ];

    volumes = [
      "cypht:/data"
      "${pkgs.cypht}/share/php/cypht:/srv/cypht:ro"
    ];
  };
}
