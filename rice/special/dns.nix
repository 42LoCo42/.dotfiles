{ config, pkgs, lib, ... }: lib.mkIf config.rice.dns {
  systemd.services.dnsmasq = {
    after = [ "network-online.target" ];
    requires = [ "network-online.target" ];
  };

  services = {
    dnsmasq = {
      enable = true;
      settings = {
        interface = config.rice.dnsmasq-interface;
        bind-interfaces = true;
        listen-address = [ "127.0.0.1" ];

        # forward to stubby, fritzbox & tailscale
        server = [ "127.0.0.1#53000" ];
        local = [
          "/fritz.box/192.168.178.1"
          "/bunny.vpn/100.100.100.100"
        ];

        # misc
        cache-size = 10000;
        filter-AAAA = true;
        log-queries = true;
        proxy-dnssec = true;
      };
    };

    stubby = {
      enable = true;
      logLevel = "info";
      settings = pkgs.stubby.settingsExample // {
        listen_addresses = [ "127.0.0.1@53000" ];
        dnssec_return_status = "GETDNS_EXTENSION_TRUE";
        upstream_recursive_servers = [
          { address_data = "1.1.1.1"; tls_port = 853; tls_auth_name = "cloudflare-dns.com"; }
          { address_data = "1.0.0.1"; tls_port = 853; tls_auth_name = "cloudflare-dns.com"; }
          { address_data = "9.9.9.9"; tls_port = 853; tls_auth_name = "dns.quad9.net"; }
          { address_data = "149.112.112.112"; tls_port = 853; tls_auth_name = "dns.quad9.net"; }
        ];
      };
    };

    resolved.enable = false;
  };
}
