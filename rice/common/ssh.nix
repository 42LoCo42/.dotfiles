{ lib, config, ... }:
let
  inherit (lib)
    filterAttrs
    flip
    mapAttrsToList
    mapNullable
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
        programs.ssh = mkMerge [
          {
            enable = true;

            addKeysToAgent = "yes";
            forwardAgent = true;
            userKnownHostsFile = knownHosts user;

            extraConfig = pipe config.aquaris.secrets [
              (filterAttrs (n: _:
                (builtins.match "user/${user}/ssh/[^/]+" n) != null))
              (mapAttrsToList (_: x: "IdentityFile ${x}\n"))
              (builtins.concatStringsSep "")
            ];

            matchBlocks.github = {
              hostname = "github.com";
              user = "git";
            };
          }

          {
            matchBlocks = {
              leonsch = rec {
                ##### private machines #####

                bunny = {
                  hostname = "exit.bunny.vpn";
                  user = "admin";
                  setEnv.TERM = "xterm-256color";
                };

                laniakea = {
                  hostname = "laniakea.bunny.vpn";
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
              };
            }.${user} or { };
          }
        ];
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
        ];
      };
  })
]
