{ config, pkgs, ... }: {
  topology.nodes.bunny-public.services.headscale = {
    name = "Headscale";
    icon = "services.headscale1";
    info = "Tailscale control plane";
    details.url.text = "https://headscale.${config.rice.domain}";
  };

  rice.caddy.cfg.headscale = ''
    import default
    reverse_proxy /sts/* headscale:8081
    reverse_proxy headscale:8080
  '';

  virtualisation.pnoc.headscale = {
    path = with pkgs; [
      coreutils
      curl
      envsubst
      jq

      headscale
      headscale-sts
    ];

    script = ''
      export CURL_HOME=/tmp
      cat << EOF > "$CURL_HOME/.curlrc"
      -fsS
      --url    "http://localhost:8080/api/v1/preauthkey"
      --header "Authorization: Bearer $HEADSCALE_API_KEY"
      EOF

      {
        # periodically clean up expired preauthkeys
        while sleep 1h; do
          curl | jq -r '
            .preAuthKeys[] | select(
              .expiration
              | sub("[.]\\d+"; "")
              | fromdate < now
            ).id' | while read -r id; do
              echo "Deleting expired preauthkey $id..."
              curl --url-query "id=$id" -X DELETE
            done
        done
      } &

      envsubst < ${./sts.yaml} > /tmp/sts.yaml
      headscale-sts --config /tmp/sts.yaml &

      exec headscale serve
    '';

    environment.DOMAIN = config.rice.domain;
    environmentFiles = [ (config.aquaris.secret "@machine/headscale") ];

    volumes = [
      "headscale:/data"
      "${config.rice.subsDomain ./config.yaml}:/etc/headscale/config.yaml:ro"
      "${./policy.jsonc}:/etc/headscale/policy.jsonc:ro"
    ];
  };
}
