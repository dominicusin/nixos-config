{ config, pkgs, ... }:

{
  services.udev.packages = with pkgs; [
    yubikey-personalization
  ];

  environment.systemPackages = with pkgs; [
    libu2f-host
    yubikey-personalization
  ];
}
