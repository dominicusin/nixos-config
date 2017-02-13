{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    (hunspellWithDicts (with hunspellDicts; [en-us]))
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
