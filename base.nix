{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    git
    termite # needed terminfo even on headless systems
    vim
    wget
  ];
}
