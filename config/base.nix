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

  #############################################################################
  ### Packages

  environment.systemPackages = with pkgs; [
    (hunspellWithDicts (with hunspellDicts; [en-us]))
    ansible
    borgbackup
    git
    gnumake
    gnupg
    htop
    keychain
    lsof
    moreutils
    mr
    nmap
    psmisc
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
