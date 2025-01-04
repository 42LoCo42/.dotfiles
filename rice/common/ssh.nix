{ lib, config, ... }:
let
  inherit (lib) flip mapNullable mkIf mkMerge pipe singleton;

  knownHosts = user: builtins.concatStringsSep "" [
    config.aquaris.persist.root
    config.users.users.${user}.home
    "/.cache/ssh-known-hosts"
  ];
in
mkMerge [
  {
    home-manager.sharedModules = singleton (hm:
      let
        user = hm.config.home.username;
        key = flip pipe [
          (name: config.aquaris.secrets."user/${user}/ssh/${name}" or null)
          (mapNullable toString)
        ];
      in
      {
        programs.ssh = {
          enable = true;
          addKeysToAgent = "yes";

          extraConfig =
            let main = key "main"; in
            mkMerge [
              "UserKnownHostsFile ${knownHosts user}"

              (mkIf (main != null) ''
                IdentityFile ${main}
              '')
            ];

          matchBlocks = {
            leonsch = rec {

              ##### private machines #####

              bunny = {
                hostname = "exit.bunny.vpn";
                user = "admin";
                identityFile = key "fido";
                forwardAgent = true;
                setEnv.TERM = "xterm-256color";
              };

              laniakea = {
                hostname = "laniakea.bunny.vpn";
                forwardAgent = true;
              };

              ##### people #####

              hannes = {
                hostname = "owo-ercanar-senpai.duckdns.org";
                port = 18213;
                user = "ercanar";
                identityFile = key "old/ed25519";
              };

              hapi = hannes // { port = 12345; };

              jana = {
                hostname = "primula25.duckdns.org";
                port = 22000;
                user = "jana";
              };

              ##### work - PIC #####

              lbmvweb = {
                hostname = "www1.d11121.lbmv.de";
                user = "www-data";
              };

              meeting2 = {
                hostname = "meeting2.planet-ic.de";
                user = "root";
                setEnv.TERM = "xterm-256color";
              };

              freepbx = {
                hostname = "195.98.195.10";
                user = "root";
                identityFile = key "old/rsa";
                setEnv.TERM = "xterm-256color";
                extraOptions = {
                  HostKeyAlgorithms = "+ssh-rsa";
                  PubkeyAcceptedKeyTypes = "+ssh-rsa";
                };
              };

              ##### utils #####

              github = {
                hostname = "github.com";
                user = "git";
              };
            };
          }.${user} or { };
        };
      });
  }

  # TODO secretKey handling should be part of aquaris
  (mkIf (builtins.hasAttr "leonsch" config.aquaris.users) {
    aquaris.secrets = pipe [ "main" "fido" "old:ed25519" "old:rsa" ] [
      (map (x: {
        name = "user:leonsch.ssh:${x}";
        value.user = "leonsch";
      }))
      builtins.listToAttrs
    ];

    home-manager.users.leonsch =
      let main = config.aquaris.secrets."user/leonsch/ssh/main"; in {
        aquaris.git.sshKeyFile = _: "${main}";

        systemd.user.tmpfiles.rules = [
          "L+ %h/.ssh/id_ed25519      - - - - ${main}"
          "L+ %h/.ssh/known_hosts     - - - - ${knownHosts "leonsch"}"
          "L+ %h/.ssh/known_hosts.old - - - - ${knownHosts "leonsch"}"
        ];
      };
  })
]
