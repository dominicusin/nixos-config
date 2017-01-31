# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ./private/wifi.nix
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

  networking.hostName = "djwhitt-laptop"; # Define your hostname.
  networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Select internationalisation properties. 
  i18n = {
    consoleFont = "Lat2-Terminus16";
    consoleKeyMap = "us";
    defaultLocale = "en_US.UTF-8";
  };

  # Set your time zone.
  time.timeZone = "US/Central";

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
    borgbackup
    chromium
    dejavu_fonts
    dmenu
    dunst
    emacs25
    evince
    git
    gitAndTools.git-annex
    gnupg
    greybird # GTK theme
    htop
    i3status
    keychain
    liberation_ttf
    libnotify
    libreoffice
    lsof
    moreutils
    mr
    nmap
    nodejs
    openjdk
    powerline-fonts
    pwgen
    rcm
    redshift
    ruby
    silver-searcher
    source-code-pro
    termite
    texlive.combined.scheme-full
    tmux
    universal-ctags
    vim
    wget
    x11_ssh_askpass
    xorg.xbacklight
    zerotierone
    zsh
  ];

  programs.zsh.enable = true;
  programs.ssh.startAgent = true;

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  services.xserver.layout = "us";
  services.xserver.xkbOptions = "ctrl:nocaps";

  services.xserver.synaptics = {
    enable = true;
    horizEdgeScroll = false;
    horizTwoFingerScroll = true;
    palmDetect = true;
    palmMinWidth = 8;
    palmMinZ = 8;
  };

  services.xserver.windowManager.i3.enable = true; 

  services.redshift = {
    enable = true;
    latitude = "43.0731";
    longitude = "-89.4012";
    temperature.day = 6200;
    temperature.night = 3700;
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
