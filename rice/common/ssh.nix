# TODO upstream to Aquaris

{ pkgs, lib, config, ... }:
let
  inherit (lib)
    concatStringsSep
    filter
    getExe
    hasPrefix
    mkIf
    mkMerge
    mkOption
    pipe
    singleton
    ;

  inherit (lib.types) anything;

  knownHosts = user: concatStringsSep "" [
    config.aquaris.persist.root
    config.users.users.${user}.home
    "/.cache/ssh-known-hosts"
  ];
in
{
  options.rice.ssh.proxy = mkOption {
    type = anything;
    default = to: x: {
      proxyCommand = "${getExe pkgs.websocat} --binary wss://${to}";
    } // x;
  };

  config.home-manager.sharedModules = singleton (hm:
    let
      user = hm.config.home.username;
      key = hm.config.aquaris.git.sshKeyFile;
      kh = knownHosts user;
    in
    {
      programs.ssh = {
        enable = true;
        enableDefaultConfig = false;

        matchBlocks = {
          "*" = {
            addKeysToAgent = "yes";
            forwardAgent = true;
            userKnownHostsFile = kh;

            identityFile = pipe config.aquaris.secrets.all [
              (filter (hasPrefix "user/${user}/ssh/"))
              (map config.aquaris.secret)
            ];
          };

          github = {
            hostname = "github.com";
            user = "git";
          };
        };
      };

      systemd.user.tmpfiles.rules = mkMerge [
        [ "L+ %h/.ssh/known_hosts - - - - ${kh}" ]
        (mkIf (key != null) [ "L+ %h/.ssh/id_ed25519 - - - - ${key}" ])
      ];
    });
}
