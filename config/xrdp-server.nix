{ config, pkgs, ... }:

{
  services = {
    xrdp = {
      enable = true;
      defaultWindowManager = "xfce4-session";
    };
    xserver.desktopManager.xfce.enable = true;
  };
}
