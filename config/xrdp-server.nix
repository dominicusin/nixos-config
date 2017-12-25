{ config, pkgs, ... }:

{
  services = {
    xrdp = {
      enable = true;
      defaultWindowManager = "openbox-session";
    };
    xserver.windowManager.openbox.enable = true;
  };
}
