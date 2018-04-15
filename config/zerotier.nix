{ config, pkgs, ... }:

{
  services.zerotierone = {
    enable = true;
  };

  networking.firewall.allowedUDPPorts = [ 9993 ];

  networking.firewall.trustedInterfaces = [ "zt0" ];
}
