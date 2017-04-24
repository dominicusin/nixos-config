{ config, pkgs, ... }:

{
  imports =
    [
      <nixpkgs/nixos/modules/virtualisation/amazon-image.nix>
      ../config/base.nix
      ../private/hosts.nix
      ../private/tahoe-us-east-2c-tahoe-lafs.nix
    ];

  #############################################################################
  ### EC2

  ec2.hvm = true;

  #############################################################################
  ### Nix

  system.autoUpgrade.enable = true;

  #############################################################################
  ### Networking

  networking.hostName = "tahoe-us-east-2c";
  networking.firewall.allowedTCPPorts = [ 3457 3458 ];
}
