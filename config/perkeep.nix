{ config, pkgs, ... }:

{
  systemd.services.perkeep = {
    description = "perkeep";
    wantedBy = [ "multi-user.target" ];
    after = [ "docker.service" ];
    serviceConfig = {
      ExecStart = ''
        ${pkgs.docker}/bin/docker run \
          --rm --network host --name perkeep \
          -v /opt/perkeep/config:/home/keepy/.config \
          -v /opt/perkeep/var:/home/keepy/var \
          gcr.io/perkeep-containers/perkeep:0.10 /home/keepy/bin/perkeepd
      '';
    };
  };

  security.acme.certs = {
    "perkeep.spcom.org" = {
      email = "admin@spcom.org";
    };
  };

  services.nginx = {
    enable = true;

    virtualHosts = {
      "perkeep.spcom.org" = {
        forceSSL = true;
        enableACME = true;

        locations = {
          "/" = {
            proxyPass = "http://127.0.0.1:3179";
          };

          "/my-search/camli/search/ws" = {
            proxyPass = "http://127.0.0.1:3179";
            extraConfig = ''
              proxy_http_version 1.1;
              proxy_set_header Host $host;
              proxy_set_header X-Real-IP $remote_addr;
              proxy_set_header Upgrade $http_upgrade;
              proxy_set_header Connection $connection_upgrade;
            '';
          };
        };
      };
    };
  };
}
