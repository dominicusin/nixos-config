{ config, pkgs, ... }:

{
  systemd.services.grafana = {
    description = "grafana";
    after = [ "network.target" ];
    serviceConfig = {
      ExecStart = ''
        ${pkgs.docker}/bin/docker run \
          --rm --network host \
          -e GF_SERVER_ROOT_URL=http://192.168.5.12/ \
          -v /opt/grafana/data:/var/grafana \
          grafana/grafana
      '';
    };
  };
}
