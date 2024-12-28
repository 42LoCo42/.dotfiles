{ config, ... }: {
  home-manager.sharedModules = [
    (hm:
      let user = hm.config.home.username; in {
        programs.ssh = {
          enable = true;
          addKeysToAgent = "yes";

          matchBlocks = {
            leonsch = rec {

              ##### private machines #####

              bunny = {
                hostname = "exit.bunny.vpn";
                user = "admin";
                identityFile = "${config.aquaris.secrets."user/${user}/ssh-bunny"}";
                forwardAgent = true;
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
              };

              hapi = hannes // { port = 12345; };

              jana = {
                hostname = "primula25.duckdns.org";
                port = 22000;
                user = "jana";
              };

              ##### work - PIC #####

              lbmvweb = {
                hostname = "193.175.55.110";
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
      })
  ];
}
