{ config, pkgs, ... }:

{
  services.pcscd.enable = true;

  services.udev.packages = with pkgs; [
    yubikey-personalization
  ];

  environment.systemPackages = with pkgs; [
    libu2f-host
    yubikey-personalization
  ];

  environment.shellInit = ''
    gpg-connect-agent /bye
    export SSH_AUTH_SOCK=$(gpgconf --list-dirs agent-ssh-socket)
  '';
}
