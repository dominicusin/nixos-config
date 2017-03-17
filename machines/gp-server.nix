{ config, pkgs, ... }:

{
  imports =
    [
      <nixpkgs/nixos/modules/virtualisation/amazon-image.nix>
      ../config/base.nix
      ../private/hosts.nix
    ];

  #############################################################################
  ### EC2

  ec2.hvm = true;

  #############################################################################
  ### Nix

  system.autoUpgrade.enable = true;

  #############################################################################
  ### Networking

  networking.hostName = "gp-server";
  networking.firewall.allowedTCPPorts = [ 80 443 ];

  #############################################################################
  ### Users

  users.extraUsers = {
    huginn = {
      home = "/srv/huginn";
      shell = pkgs.bashInteractive;
    };
  };

  #############################################################################
  ### Services

  services.postgresql = {
    enable = true;
    authentication =  pkgs.lib.mkOverride 10 ''
      local all all              ident
      host  all all 127.0.0.1/32 md5
      host  all all ::1/128      md5
    '';
  };

  services.jenkins.enable = true;

  # Huginn
  systemd.services.huginn-web = {
    enable = true;
    description = "Huginn Web Server";
    path = [ pkgs.bash ];
    after = [ "network.target" ];
    wants = [ "network.target" ];
    environment = {
      HOME = "/srv/huginn";
      NIX_PATH = "nixpkgs=/nix/var/nix/profiles/per-user/root/channels/nixos/nixpkgs:nixos-config=/etc/nixos/configuration.nix:/nix/var/nix/profiles/per-user/root/channels";
      TEMPDIR = "/srv/huginn/huginn/tmp";
    };
    serviceConfig = {
      WorkingDirectory = "/srv/huginn/huginn";
      ExecStart = "/run/current-system/sw/bin/nix-shell . --run 'bundle exec dotenv unicorn -c config/unicorn.rb'";
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
    environment = {
      HOME = "/srv/huginn";
      NIX_PATH = "nixpkgs=/nix/var/nix/profiles/per-user/root/channels/nixos/nixpkgs:nixos-config=/etc/nixos/configuration.nix:/nix/var/nix/profiles/per-user/root/channels";
      TEMPDIR = "/srv/huginn/huginn/tmp";
    };
    serviceConfig = {
      WorkingDirectory = "/srv/huginn/huginn";
      ExecStart = "/run/current-system/sw/bin/nix-shell . --run 'bundle exec dotenv rails runner bin/threaded.rb'";
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
              proxy_set_header Host $host:$server_port;
              proxy_set_header X-Real-IP $remote_addr;
              proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
              proxy_set_header X-Forwarded-Proto $scheme;
              proxy_redirect http:// https://;
            '';
          };
        };
      };
    };
  };
}
