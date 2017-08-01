# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [
      ../hardware-configuration.nix
      ../config/base.nix
      ../private/mail.nix
      ../private/hosts.nix
    ];

  boot.loader.grub.device = "/dev/sda";

  #############################################################################
  ### Localization

  i18n = {
    consoleFont = "Lat2-Terminus16";
    consoleKeyMap = "us";
    defaultLocale = "en_US.UTF-8";
  };

  time.timeZone = "US/Central";

  #############################################################################
  ### Networking

  networking.hostName = "home-gp-server";
  networking.firewall.allowedTCPPorts = [ 3457 3458 ];

  #############################################################################
  ### Users

  security.sudo.wheelNeedsPassword = false;

  users.extraUsers.djwhitt = {
    isNormalUser = true;
    home = "/home/djwhitt";
    shell = "/run/current-system/sw/bin/bash";
    extraGroups = [ "wheel" ];
  };

  #############################################################################
  ### Packages

  virtualisation = {
    docker = {
      enable = true;
      enableOnBoot = true;
    };
  };

  #############################################################################
  ### Services

  services.openssh.enable = true;

  #############################################################################

  # The NixOS release to be compatible with for stateful data such as databases.
  system.stateVersion = "17.03";
}
