{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    borgbackup
    git
    htop
    keychain
    moreutils # primarily for chronic
    nmap
    rcm # TODO: needs update to 1.3.1
    silver-searcher
    termite # needed for terminfo even on headless systems
    tmux
    vim
    wget
  ];
}
