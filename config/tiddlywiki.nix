{ config, pkgs, ... }:

{
  systemd.services.tiddlywiki-djwhitt = {
    description = "tiddlywiki-djwhitt";
    after = [ "network.target" ];
    serviceConfig = {
      ExecStart = ''
        /opt/tiddlywiki/djwhitt.sh
      '';
    };
  };

  security.acme.certs = {
    "djwhitt.tw.spcom.org" = {
      email = "admin@spcom.org";
    };
  };

  services.nginx = {
    enable = true;

    virtualHosts = {
      "djwhitt.tw.spcom.org" = {
        forceSSL = true;
        enableACME = true;

        locations = {
          "/" = {
            proxyPass = "http://127.0.0.1:20000";
            extraConfig = ''
              proxy_redirect http:// https://;
            '';
          };
        };
      };
    };
  };
}
