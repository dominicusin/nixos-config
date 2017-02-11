{ config, pkgs, ... }:

{
  imports = [ <nixpkgs/nixos/modules/virtualisation/amazon-image.nix> ];
  ec2.hvm = true;

  networking.hostName = "gp-server";

  environment.systemPackages = with pkgs; [
    termite
    vim
  ];
}
