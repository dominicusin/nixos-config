{ config, pkgs, ... }:

{
  imports =
    [
      <nixpkgs/nixos/modules/virtualisation/amazon-image.nix>
      ../config/base.nix
    ];

  ec2.hvm = true;

  networking.hostName = "gp-server";
}
