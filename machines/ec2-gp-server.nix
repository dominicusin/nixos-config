{ config, pkgs, ... }:

{
  imports =
    [
      <nixpkgs/nixos/modules/virtualisation/amazon-image.nix>
      ../config/base.nix
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
    fedwiki = {
      home = "/srv/fedwiki";
      shell = pkgs.bashInteractive;
    };
    huginn = {
      home = "/srv/huginn";
      shell = pkgs.bashInteractive;
    };
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

  # Federated Wiki
  systemd.services.fedwiki = {
    enable = true;
    description = "Federated Wiki Server";
    path = [ pkgs.bash ];
    after = [ "network.target" ];
    wants = [ "network.target" ];
    serviceConfig = {
      ExecStart = "/var/setuid-wrappers/su - -c 'nix-shell . --run /srv/fedwiki/.npm-packages/bin/wiki' fedwiki";
      Restart = "always";
      RestartSec = 30;
    };
  };

  # Huginn
  systemd.services.huginn-web = {
    enable = true;
    description = "Huginn Web Server";
    path = [ pkgs.bash ];
    after = [ "network.target" ];
    wants = [ "network.target" ];
    serviceConfig = {
      ExecStart = "/var/setuid-wrappers/su - -c \"cd huginn && nix-shell . --run 'bundle exec dotenv unicorn -c config/unicorn.rb' \" huginn";
      ExecReload = "/run/current-system/sw/bin/kill -s USR2 $MAINPID";
      ExecStop = "/run/current-system/sw/bin/kill -s QUIT $MAINPID";
      Restart = "always";
      RestartSec = 30;
      PIDFile = "/srv/huginn/huginn/tmp/pids/unicorn.pid";
    };
  };

  systemd.services.huginn-jobs = {
    enable = true;
    description = "Huginn Jobs";
    path = [ pkgs.bash ];
    after = [ "network.target" ];
    wants = [ "network.target" ];
    serviceConfig = {
      ExecStart = "/var/setuid-wrappers/su - -c \"cd huginn && nix-shell . --run 'bundle exec dotenv rails runner bin/threaded.rb' \" huginn";
      Restart = "always";
      RestartSec = 30;
    };
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
    "huginn.spcom.org" = {
      email = "huginn@spcom.org";
    };
    "jenkins.spcom.org" = {
      email = "jenkins@spcom.org";
    };
    "wiki.djwhitt.com" = {
      email = "admin@djwhitt.com";
    };
  };

  services.nginx = {
    enable = true;

    appendHttpConfig = ''
      upstream huginn {
        server unix:/srv/huginn/huginn/tmp/sockets/unicorn.socket fail_timeout=0;
      }
    '';

    virtualHosts = {
      "huginn.spcom.org" = {
        port = 443;
        forceSSL = true;
        enableACME = true;

        root = "/srv/huginn/huginn/public";
        extraConfig = ''
          client_max_body_size 20m;
          error_page 502 /502.html;
        '';

        locations = {
          "/" = {
            extraConfig = ''
              try_files $uri $uri/index.html $uri.html @huginn;
            '';
          };
          "@huginn" = {
            proxyPass = "http://huginn";
            extraConfig = ''
              proxy_read_timeout      300;
              proxy_connect_timeout   300;
              proxy_redirect          off;

              proxy_set_header    Host                $http_host;
              proxy_set_header    X-Real-IP           $remote_addr;
              proxy_set_header    X-Forwarded-For     $proxy_add_x_forwarded_for;
              proxy_set_header    X-Forwarded-Proto   $scheme;
              proxy_set_header    X-Frame-Options     SAMEORIGIN;
            '';
          };
          "~ ^/(assets)/" = {
            root = "/srv/huginn/huginn/public";
            extraConfig = ''
              gzip_static on; # to serve pre-gzipped version
              expires max;
              add_header Cache-Control public;
            '';
          };
        };
      };

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

     "wiki.djwhitt.com" = {
        port = 443;
        forceSSL = true;
        enableACME = true;

        locations = {
          "/" = {
            proxyPass = "http://127.0.0.1:3000";
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
    };
  };
}
