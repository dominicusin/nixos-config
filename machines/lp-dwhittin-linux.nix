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
      #../private/mail.nix
      #../private/hosts.nix
    ];

  #############################################################################
  ### Boot and Hardware

  # Use the systemd-boot EFI boot loader.
  #boot.loader.systemd-boot.enable = true;
  #boot.loader.efi.canTouchEfiVariables = true;

  boot.kernelModules = [ "virtio" ];

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

  networking.hostName = "lp-dwhittin-linux"; # Define your hostname.
  networking.networkmanager.enable = true;
  networking.firewall.allowedTCPPorts = [ 3000 ];

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
  services.gnome3.at-spi2-core.enable = true;
  services.gnome3.gnome-keyring.enable = true;
  services.openssh.enable = true;
  services.printing.enable = true;
  services.xrdp.enable = true;

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

  virtualisation = {
    docker = {
      enable = true;
      enableOnBoot = true;
    };
  };

  nixpkgs.config = {
    allowUnfree = true;
  };

  services.udev.packages = with pkgs; [
    yubikey-personalization
  ];

  # List packages installed in system profile. To search by name, run:
  # $ nix-env -qaP | grep wget
  environment.systemPackages = with pkgs; [
    (hunspellWithDicts (with hunspellDicts; [en-us]))
    awscli
    bash
    binutils
    bundler
    emacs25
    exercism
    file
    gnuplot
    go
    graphviz
    jq
    keychain
    libnotify
    libreoffice
    libu2f-host
    lz4
    nix-repl
    nodejs
    obnam
    openssl
    patchelf
    pavucontrol
    pciutils
    pinentry
    pwgen
    rake
    ranger
    ruby
    snappy
    sqlite-interactive
    swiProlog
    sylpheed
    tig
    tmate
    universal-ctags
    usbutils
    xfontsel
    xrdp
    yubikey-personalization
    zip
  ];

  environment.pathsToLink = [ "/include" ];


  # The NixOS release to be compatible with for stateful data such as databases.
  system.stateVersion = "17.09";
}
