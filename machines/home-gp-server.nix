# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [
      ../hardware-configuration.nix
      ../config/base.nix
      ../config/zerotier.nix
      ../config/prometheus.nix
      ../config/grafana.nix
      ../config/sourcegraph.nix
      ../private/mail.nix
      ../private/hosts.nix
    ];

  boot.loader.grub.device = "/dev/sda";

  #############################################################################
  ### Localization

  time.timeZone = "US/Central";

  #############################################################################
  ### Networking

  networking.hostName = "home-gp-server";
  networking.firewall.allowedTCPPorts = [ 80 443 3000 7080 ];

  #############################################################################
  ### Users

  security.sudo.wheelNeedsPassword = false;

  users.extraUsers.djwhitt = {
    isNormalUser = true;
    uid = 1000;
    home = "/home/djwhitt";
    shell = "/run/current-system/sw/bin/zsh";
    extraGroups = [ "docker" "wheel" ];
  };

  #############################################################################
  ### Packages

  programs = {
    java.enable = true;
    zsh.enable = true;
  };

  environment.systemPackages = with pkgs; [
    docker_compose
    emacs25
    go
    graphviz
    nodejs
    sqlite-interactive
    universal-ctags
  ];

  #############################################################################

  # The NixOS release to be compatible with for stateful data such as databases.
  system.stateVersion = "18.03";
}
