{ config, pkgs, ... }:

{
  #############################################################################
  ### Virtualisation

  boot.kernelModules = [ "virtio" ];

  virtualisation = {
    libvirtd = {
      enable = true;
      qemuPackage = pkgs.qemu_kvm;
    };
  };

  #############################################################################
  ### Services

  services = {
    kbfs = {
      enable = true;
      mountPoint = "%h/Keybase";
    };

    keybase.enable = true;

    tarsnap = {
      enable = true;
      archives = {
        home = {
          directories = [ "/home" ];
          period = "*-*-* 02:00:00";
          excludes = [
            "*/node_modules/*"
            "*/tmp/*"
            "/home/*/.dbus/"
            "/home/*/.gvfs/"
            "/home/*/.steam/"
          ];
        };
      };
    };
  };

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

  services.gnome3.at-spi2-core.enable = true;
  services.gnome3.gnome-keyring.enable = true;

  #############################################################################
  ### Fonts

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
  ### Programs and Packages

  nixpkgs.config = {
    chromium = {
      enablePepperPDF = true;
      enableNacl = true;
    };
  };

  programs = {
    chromium.enable = true;
    ssh.startAgent = false;
    wireshark.enable = true;
  };

  security.wrappers = {
    slock.source = "${pkgs.slock}/bin/slock";
  };

  environment.systemPackages = with pkgs; [
    (hunspellWithDicts (with hunspellDicts; [en-us]))
    alacritty
    anki
    arandr
    atom
    blueman
    chromium
    copyq
    dmenu
    dunst
    evince
    freerdp
    gimp
    gitAndTools.git-annex
    glxinfo
    gnome3.adwaita-icon-theme
    gnome3.dconf
    gnome3.dconf-editor
    gnome3.gnome_keyring
    gnome3.gnome_terminal
    gnome3.gnome_themes_standard
    i3status
    keybase-gui
    leafpad
    libnotify
    libreoffice
    lightdm
    networkmanagerapplet
    pamixer
    pavucontrol
    pinentry
    python27Packages.syncthing-gtk
    redshift
    slack
    slock
    smplayer
    syncthing
    universal-ctags
    virtmanager
    vlc
    wireshark
    x11_ssh_askpass
    xfontsel
    xfontsel
    xorg.xbacklight
    xorg.xhost
    xorg.xwininfo
    xss-lock
  ];
}
