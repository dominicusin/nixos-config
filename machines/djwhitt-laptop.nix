# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ../hardware-configuration.nix
      ../config/base.nix
      ../private/wifi.nix
    ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.initrd.luks.devices = [
    {
      name = "root";
      device = "/dev/disk/by-uuid/de3fc10d-39aa-4508-96b8-2a7fd625ccd8";
      preLVM = true;
      allowDiscards = true;
    }
  ];

  hardware.enableAllFirmware = true;

  # Select internationalisation properties.
  i18n = {
    consoleFont = "Lat2-Terminus16";
    consoleKeyMap = "us";
    defaultLocale = "en_US.UTF-8";
  };

  # Set your time zone.
  time.timeZone = "US/Central";

  #############################################################################
  ### Networking

  networking.hostName = "djwhitt-laptop"; # Define your hostname.
  networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  #############################################################################
  ### Packages

  nixpkgs.config = {
    allowUnfree = true;

    chromium = {
      enablePepperFlash = true;
      enablePepperPDF = true;
    };
  };

  # List packages installed in system profile. To search by name, run:
  # $ nix-env -qaP | grep wget
  environment.systemPackages = with pkgs; [
    (hunspellWithDicts (with hunspellDicts; [en-us]))
    anki
    awscli
    chromium
    dmenu
    dunst
    emacs25
    evince
    gitAndTools.git-annex
    gnome3.adwaita-icon-theme
    gnome3.gnome_themes_standard
    hexchat
    i3lock
    i3status
    keychain
    leafpad
    libnotify
    libreoffice
    nixops
    nodejs
    openjdk
    pciutils
    psmisc
    pwgen
    redshift
    ruby
    sqlite-interactive
    sylpheed
    texlive.combined.scheme-full
    universal-ctags
    unzip
    usbutils
    x11_ssh_askpass
    xautolock
    xorg.xbacklight
  ];

  environment.pathsToLink = [ "/include" ];

  programs.zsh.enable = true;
  programs.ssh.startAgent = true;

  #############################################################################
  ### Services

  services.avahi.enable = true;
  services.bitlbee.enable = true;
  services.openssh.enable = true;
  services.printing.enable = true;

  #############################################################################
  ### X

  services.xserver.enable = true;

  services.xserver.layout = "us";
  services.xserver.xkbOptions = "ctrl:nocaps";

  services.xserver.libinput = {
    enable = true;
  };

  services.xserver.serverFlagsSection = ''
    Option "BlankTime" "0"
    Option "StandbyTime" "0"
    Option "SuspendTime" "0"
    Option "OffTime" "5"
  '';

  services.xserver.windowManager.i3.enable = true;

  services.redshift = {
    enable = true;
    latitude = "43.0731";
    longitude = "-89.4012";
    temperature.day = 6200;
    temperature.night = 3700;
  };

  systemd.user.services.redshift = {
    conflicts = [ "exit.target" ];
  };

  fonts = {
    fonts = with pkgs; [
      cantarell_fonts
      dejavu_fonts
      liberation_ttf
      powerline-fonts
      source-code-pro
      ttf_bitstream_vera
    ];
  };

  users.extraUsers.djwhitt = {
    isNormalUser = true;
    uid = 1000;
    home = "/home/djwhitt";
    shell = "/run/current-system/sw/bin/zsh";
    extraGroups = [ "wheel" ];
  };

  security.sudo.wheelNeedsPassword = false;

  # The NixOS release to be compatible with for stateful data such as databases.
  system.stateVersion = "16.09";
}
