{ config, ... }: {
  # password-protected immich share
  rice.caddy.cfg.avh = ''
    redir https://img.${config.rice.domain}/share/WRRh4tVvPvLC4k6rmcZRlKQiZ_B5R9P0xFV9-HG5WGWyuQxKENLSf8oAacjR8Lp3zio
  '';
}
