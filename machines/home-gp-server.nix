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
      ../config/perkeep.nix
      ../config/tiddlywiki.nix
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
  ### Services

  services.tarsnap = {
    enable = true;
    archives = {
      services = {
        directories = [ "/opt/grafana" "/opt/perkeep/config" "/opt/prometheus/etc" "/opt/tiddlywiki" ];
        period = "*-*-* 04:00:00";
        excludes = [];
      };
    };
  };

  systemd.services.tarsnap-services-expire = {
    script = ''
      /run/current-system/sw/bin/tarsnapper \
        -o keyfile /root/tarsnap.key \
        -o cachedir /var/cache/tarsnap/root-tarsnap.key \
        --dateformat "%Y%m%d%H%M%S" \
        --target "services-\$date" \
        --deltas 1d 7d 30d 90d - expire
    '';
    wantedBy = [ "default.target" ];
  };

  systemd.timers.tarsnap-services-expire = {
    timerConfig = {
      Unit = "tarsnap-home-expire.service";
      OnCalendar = "*-*-* 04:00:00";
    };
    wantedBy = [ "default.target" ];
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
    tarsnapper
    universal-ctags
  ];

  #############################################################################

  # The NixOS release to be compatible with for stateful data such as databases.
  system.stateVersion = "18.03";
}
