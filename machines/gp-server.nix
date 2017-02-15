{ config, pkgs, ... }:

{
  imports =
    [
      <nixpkgs/nixos/modules/virtualisation/amazon-image.nix>
      ../config/base.nix
      ../private/hosts.nix
    ];

  ec2.hvm = true;

  networking.hostName = "gp-server";

  environment.systemPackages = with pkgs; [
    boot
    certbot
    nodejs
    openjdk
  ];

  services.jenkins.enable = true;
  services.nginx.enable = true;
}
