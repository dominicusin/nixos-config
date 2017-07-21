{ config, pkgs, ... }:

{
  imports =
    [
      <nixpkgs/nixos/modules/virtualisation/amazon-image.nix>
      ../config/base.nix
      ../config/tahoe.nix
      ../private/hosts.nix
      ../private/ec2-gp-server-tahoe-lafs.nix
    ];

  #############################################################################
  ### EC2

  ec2.hvm = true;

  #############################################################################
  ### Nix

  system.autoUpgrade.enable = true;

  #############################################################################
  ### Networking

  networking.hostName = "ec2-gp-server";
  networking.firewall.allowedTCPPorts = [ 80 443 3457 3458 ];

  #############################################################################
  ### Users

  users.extraUsers = {
    memocorder = {
      home = "/srv/memocorder";
      shell = pkgs.bashInteractive;
    };
  };

  #############################################################################
  ### Services

  services.jenkins.enable = true;
  services.redis.enable = true;
  services.postgresql = {
    enable = true;
    authentication = pkgs.lib.mkOverride 10 ''
      local all all              ident
      host  all all 127.0.0.1/32 md5
      host  all all ::1/128      md5
    '';
  };

  # Memocorder
  systemd.services.memocorder = {
    enable = true;
    description = "Memocorder Server";
    path = [ pkgs.bash ];
    after = [ "network.target" ];
    wants = [ "network.target" ];
    serviceConfig = {
      WorkingDirectory = "/srv/memocorder/memocorder";
      ExecStart = "/var/setuid-wrappers/su - -c \"cd memocorder && nix-shell . --run 'boot run' \" memocorder";
      Restart = "always";
      RestartSec = 30;
    };
  };

  #############################################################################
  ### Sites

  security.acme.certs = {
    "jenkins.spcom.org" = {
      email = "jenkins@spcom.org";
    };
  };

  services.nginx = {
    enable = true;

    virtualHosts = {
      "jenkins.spcom.org" = {
        port = 443;
        forceSSL = true;
        enableACME = true;

        locations = {
          "/" = {
            proxyPass = "http://127.0.0.1:8080";
            extraConfig = ''
              proxy_set_header    Host                $host:$server_port;
              proxy_set_header    X-Real-IP           $remote_addr;
              proxy_set_header    X-Forwarded-For     $proxy_add_x_forwarded_for;
              proxy_set_header    X-Forwarded-Proto   $scheme;
              proxy_set_header    X-Frame-Options     SAMEORIGIN;
              proxy_redirect      http:// https://;
            '';
          };
        };
      };

      "staging.memocorder.com" = {
        port = 443;
        enableSSL = true;
        forceSSL = true;
        sslCertificate = "/srv/memocorder/certs/staging_memocorder_com.crt";
        sslCertificateKey = "/srv/memocorder/certs/staging_memocorder_com.key";

        locations = {
          "/" = {
            proxyPass = "http://127.0.0.1:4000";
            extraConfig = ''
              proxy_set_header    Host                $host:$server_port;
              proxy_set_header    X-Real-IP           $remote_addr;
              proxy_set_header    X-Forwarded-For     $proxy_add_x_forwarded_for;
              proxy_set_header    X-Forwarded-Proto   $scheme;
              proxy_set_header    X-Frame-Options     SAMEORIGIN;
              proxy_redirect      http:// https://;
            '';
          };

          "/chsk" = {
            proxyPass = "http://127.0.0.1:4000";
            extraConfig = ''
              proxy_http_version  1.1;
              proxy_set_header    Upgrade             $http_upgrade;
              proxy_set_header    Connection          "upgrade";
              proxy_set_header    Host                $host:$server_port;
              proxy_set_header    X-Real-IP           $remote_addr;
              proxy_set_header    X-Forwarded-For     $proxy_add_x_forwarded_for;
              proxy_set_header    X-Forwarded-Proto   $scheme;
              proxy_set_header    X-Frame-Options     SAMEORIGIN;
              proxy_redirect      http:// https://;
            '';
          };
        };
      };
    };
  };
}
