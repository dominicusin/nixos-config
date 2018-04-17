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

  environment.systemPackages = with pkgs; [
    (hunspellWithDicts (with hunspellDicts; [en-us]))
    alacritty
    anki
    atom
    blueman
    chromium
    copyq
    evince
    freerdp
    gimp
    gitAndTools.git-annex
    glxinfo
    i3status
    keybase-gui
    leafpad
    libnotify
    libreoffice
    lightdm
    networkmanagerapplet
    pinentry
    python27Packages.syncthing-gtk
    redshift
    slack
    smplayer
    syncthing
    universal-ctags
    virtmanager
    vlc
    wireshark
    x11_ssh_askpass
    xfontsel
    xorg.xbacklight
    xorg.xhost
    xorg.xwininfo
  ];
}
