{
  network.description = "Spcom";

  server =
    { config, pkgs, ... }:
    {
      environment.systemPackages = with pkgs; [
        wget
      ];
    };
}
