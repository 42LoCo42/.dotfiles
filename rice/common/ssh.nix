{ lib, config, ... }:
let
  inherit (lib)
    concatLines
    flip
    hasPrefix
    mkIf
    mkMerge
    pipe
    singleton
    ;

  knownHosts = user: builtins.concatStringsSep "" [
    config.aquaris.persist.root
    config.users.users.${user}.home
    "/.cache/ssh-known-hosts"
  ];
in
{
  home-manager.sharedModules = singleton (hm:
    let
      user = hm.config.home.username;
      key = hm.config.aquaris.git.sshKeyFile;
      kh = knownHosts user;
    in
    {
      programs.ssh = {
        enable = true;

        addKeysToAgent = "yes";
        forwardAgent = true;
        userKnownHostsFile = kh;

        extraConfig = pipe config.aquaris.secrets.all [
          (builtins.filter (hasPrefix "user/${user}/ssh/"))
          (map (flip pipe [
            config.aquaris.secret
            (x: "IdentityFile ${x}")
          ]))
          concatLines
        ];

        matchBlocks.github = {
          hostname = "github.com";
          user = "git";
        };
      };

      systemd.user.tmpfiles.rules = mkMerge [
        [ "L+ %h/.ssh/known_hosts - - - - ${kh}" ]
        (mkIf (key != null) [ "L+ %h/.ssh/id_ed25519 - - - - ${key}" ])
      ];
    });
}
