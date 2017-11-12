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

  # Blank screen after 10 minutes
  services.xserver.serverFlagsSection = ''
    Option "BlankTime" "10"
    Option "StandbyTime" "0"
    Option "SuspendTime" "0"
    Option "OffTime" "10"
  '';

  services.xserver.windowManager.i3.enable = true;

  services.redshift = {
    enable = true;
    latitude = "43.0731";
    longitude = "-89.4012";
    temperature.day = 6200;
    temperature.night = 3700;
  };

  # Restart Redshift when X restarts
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

  #############################################################################
  ### Packages

  programs = {
    chromium.enable = true;
    java.enable = true;
    mtr.enable = true;
    ssh.startAgent = true;
    wireshark.enable = true;
    zsh.enable = true;
  };

  virtualisation = {
    docker = {
      enable = true;
      enableOnBoot = true;
    };
    libvirtd = {
      enable = true;
      enableKVM = true;
    };
  };

  nixpkgs.config = {
    allowUnfree = true;

    chromium = {
      #enablePepperFlash = true;
      enablePepperPDF = true;
    };
  };

  security.wrappers = {
    slock.source = "${pkgs.slock}/bin/slock";
  };

  services.udev.packages = with pkgs; [
    yubikey-personalization
  ];

  # List packages installed in system profile. To search by name, run:
  # $ nix-env -qaP | grep wget
  environment.systemPackages = with pkgs; [
    (hunspellWithDicts (with hunspellDicts; [en-us]))
    anki
    arandr
    awscli
    bash
    binutils
    blueman
    bundler
    chromium
    dmenu
    dunst
    emacs25
    evince
    exercism
    gimp
    gitAndTools.git-annex
    glxinfo
    gnome3.adwaita-icon-theme
    gnome3.dconf
    gnome3.gnome_keyring
    gnome3.gnome_terminal
    gnome3.gnome_themes_standard
    gnuplot
    go
    graphviz
    hexchat
    i3status
    jq
    keychain
    leafpad
    libnotify
    libreoffice
    libu2f-host
    lightdm
    networkmanagerapplet
    nix-repl
    nodejs
    obnam
    openssl
    patchelf
    pavucontrol
    pciutils
    phantomjs2
    pinentry
    pwgen
    python27Packages.syncthing-gtk
    rake
    ranger
    redshift
    ruby
    slack
    slock
    smplayer
    sqlite-interactive
    sylpheed
    syncthing
    #texlive.combined.scheme-full
    tig
    tmate
    universal-ctags
    usbutils
    virtmanager
    wireshark
    x11_ssh_askpass
    xfontsel
    xorg.xbacklight
    xss-lock
    yubikey-personalization
    zip
  ];

  environment.pathsToLink = [ "/include" ];

  # The NixOS release to be compatible with for stateful data such as databases.
  system.stateVersion = "17.09";
}
