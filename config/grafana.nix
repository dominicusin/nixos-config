{ config, pkgs, ... }:

{
  systemd.services.grafana = {
    description = "grafana";
    wantedBy = [ "multi-user.target" ];
    after = [ "docker.service" ];
    serviceConfig = {
      ExecStart = ''
        ${pkgs.docker}/bin/docker run \
          --rm --network host --name grafana \
          -e GF_SERVER_ROOT_URL=http://192.168.5.12/ \
          -v /opt/grafana/data:/var/grafana \
          grafana/grafana
      '';
    };
  };

  security.acme.certs = {
    "grafana.spcom.org" = {
      email = "admin@spcom.org";
    };
  };

  services.nginx = {
    enable = true;

    virtualHosts = {
      "grafana.spcom.org" = {
        forceSSL = true;
        enableACME = true;

        locations = {
          "/" = {
            proxyPass = "http://127.0.0.1:3000";
            extraConfig = ''
              proxy_redirect http:// https://;
            '';
          };
        };
      };
    };
  };
}
