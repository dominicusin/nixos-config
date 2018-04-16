# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  #############################################################################
  ### Imports

  imports =
    [ # Include the results of the hardware scan.
      ../hardware-configuration.nix
      ../config/base.nix
      ../config/desktop.nix
      ../config/yubikey.nix
      ../config/xrdp-server.nix
      ../config/zerotier.nix
      #../private/mail.nix
      #../private/hosts.nix
    ];

  #############################################################################
  ### Boot and Hardware

  # Use the systemd-boot EFI boot loader.
  #boot.loader.systemd-boot.enable = true;
  #boot.loader.efi.canTouchEfiVariables = true;

  boot.loader.grub.enable = true;
  boot.loader.grub.version = 2;
  boot.loader.grub.device = "nodev";
  boot.initrd.luks.devices = [ { name = "cryptroot"; device = "/dev/nvme0n1p3"; preLVM = true; } ];

  hardware = {
    bluetooth = {
      enable = true;
    };
    bumblebee = {
      connectDisplay = true;
      enable = true;
    };
    cpu.intel.updateMicrocode = true;
    enableAllFirmware = true;
    opengl = {
      driSupport32Bit = true;
      extraPackages = with pkgs; [ vaapiIntel ];
    };
    pulseaudio = {
      enable = true;
      package = pkgs.pulseaudioFull;
      support32Bit = true;
    };
  };

  #############################################################################
  ### Localization

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

  networking.hostName = "lp-dwhittin-linux";
  networking.networkmanager.enable = true;

  #############################################################################
  ### Power Management

  services.logind.extraConfig = "HandleLidSwitch=ignore";

  #############################################################################
  ### Services

  services.avahi = {
    enable = true;
    nssmdns = true;
  };
  #services.bitlbee.enable = true;
  services.openssh.enable = true;
  services.printing.enable = true;

  #############################################################################
  ### Users

  security.sudo.wheelNeedsPassword = false;

  users.extraUsers.dwhittington = {
    isNormalUser = true;
    #uid = 1000;
    home = "/home/dwhittington";
    shell = "/run/current-system/sw/bin/zsh";
    extraGroups = [ "docker" "libvirtd" "networkmanager" "wheel" "whireshark" ];
  };

  #############################################################################
  ### X

  services.xserver.enable = true;
  services.xserver.exportConfiguration = true;

  # Video
  services.xserver.videoDrivers = [ "intel nvidia" ];

  # Keyboard
  services.xserver.layout = "us";
  services.xserver.xkbOptions = "ctrl:nocaps";

  # Touchpad/mouse
  services.xserver.multitouch.enable = true;

  #############################################################################
  ### Programs and Packages

  programs = {
    java.enable = true;
    mtr.enable = true;
    zsh.enable = true;
  };

  nixpkgs.config = {
    allowUnfree = true;
  };

  # List packages installed in system profile. To search by name, run:
  # $ nix-env -qaP | grep wget
  environment.systemPackages = with pkgs; [
    (hunspellWithDicts (with hunspellDicts; [en-us]))
    binutils
    bundler
    clojure
    easyrsa
    emacs25
    exercism
    firefox
    gnuplot
    go
    graphviz
    libreoffice
    lz4
    nodejs-8_x
    openssl
    patchelf
    pavucontrol
    pcmanfm
    pinentry
    rake
    ruby
    snappy
    sqlite-interactive
    strongswan
    swiProlog
    tig
    tmate
    universal-ctags
    xfontsel
  ];

  environment.pathsToLink = [ "/include" ];

  # The NixOS release to be compatible with for stateful data such as databases.
  system.stateVersion = "18.03";
}
