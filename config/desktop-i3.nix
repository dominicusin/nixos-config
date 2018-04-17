{ config, pkgs, ... }:

{
  #############################################################################
  ### Services

  services.xserver.windowManager.i3.enable = true;

  services.gnome3.at-spi2-core.enable = true;
  services.gnome3.gnome-keyring.enable = true;

  #############################################################################
  ### Programs and Packages

  security.wrappers = {
    slock.source = "${pkgs.slock}/bin/slock";
  };

  environment.systemPackages = with pkgs; [
    arandr
    dmenu
    dunst
    gnome3.adwaita-icon-theme
    gnome3.dconf
    gnome3.dconf-editor
    gnome3.gnome_keyring
    gnome3.gnome_terminal
    gnome3.gnome_themes_standard
    networkmanagerapplet
    pamixer
    pavucontrol
    slock
    xss-lock
  ];
}
