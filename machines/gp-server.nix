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
  ### Services

  services.jenkins.enable = true;

  #############################################################################
  ### Users

  #users.extraUsers.djwhitt = {
  #  home = "/srv/fedwiki";
  #};

  #############################################################################
  ### Sites

  security.acme.certs = {
    "jenkins.spcom.org" = {
      email = "jenkins@spcom.org";
    };
    # "wiki.djwhitt.com" = {
    #   email = "admin@djwhitt.com";
    # };
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
              proxy_set_header        Host $host:$server_port;
              proxy_set_header        X-Real-IP $remote_addr;
              proxy_set_header        X-Forwarded-For $proxy_add_x_forwarded_for;
              proxy_set_header        X-Forwarded-Proto $scheme;
              proxy_redirect http:// https://;
            '';
          };
        };
      };
    };
  };
}
