{ config, pkgs, ... }:

{
  #############################################################################
  ### Networking

  networking.firewall.allowedUDPPorts = [ 9993 ];

  systemd.services.zerotier-one = {
    enable = true;
    description = "ZeroTier One";
    after = [ "network.target" ];
    wants = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      ExecStart = "${pkgs.zerotierone}/bin/zerotier-one";
      Restart = "always";
      KillMode = "process";
    };
  };

  networking.firewall.trustedInterfaces = [ "zt0" ];

  # ports for mosh
  networking.firewall.allowedUDPPortRanges = [ { from = 60000; to = 61000; } ];

  #############################################################################
  ### Services

  services = {
    tarsnap.enable = true;
  };

  #############################################################################
  ### Packages

  environment.systemPackages = with pkgs; [
    (hunspellWithDicts (with hunspellDicts; [en-us]))
    bind
    borgbackup
    git
    gnumake
    gnupg
    htop
    keychain
    lsof
    moreutils
    mosh
    mr
    nmap
    psmisc
    python2Full
    rcm
    silver-searcher
    termite # needed for terminfo even on headless systems
    tmux
    unzip
    vim
    wget
    zerotierone
    zsh
  ];
}
