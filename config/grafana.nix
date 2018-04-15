{ config, pkgs, ... }:

{
  services = {
    grafana = {
      enable = true;
      addr = "0.0.0.0";
      domain = "home-gp-server";
      rootUrl = "http://home-gp-server:3000/";
    };
  };

  networking.firewall.allowedTCPPorts = [ 3000 ];
}
