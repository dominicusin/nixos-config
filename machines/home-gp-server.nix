# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [
      ../hardware-configuration.nix
      ../config/base.nix
      ../config/tahoe.nix
      ../private/mail.nix
      ../private/hosts.nix
      ../private/home-gp-server-tahoe-lafs.nix
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

  users.extraUsers = {
    camlistore = {
      home = "/srv/camlistore";
      shell = pkgs.bashInteractive;
    };
  };

  #############################################################################
  ### Services

  services.openssh.enable = true;

  # Camlistore
  systemd.services.camlistore = {
    enable = true;
    description = "Camlistore";
    path = [ pkgs.bash ];
    after = [ "network.target" ];
    wants = [ "network.target" ];
    serviceConfig = {
      WorkingDirectory = "/srv/camlistore";
      ExecStart = "/var/setuid-wrappers/su - -c camlistored camlistore";
      Restart = "always";
      RestartSec = 30;
    };
  };

  #############################################################################
  ### Packages

  environment.systemPackages = with pkgs; [
    camlistore
  ];

  #############################################################################

  # The NixOS release to be compatible with for stateful data such as databases.
  system.stateVersion = "16.09";
}
