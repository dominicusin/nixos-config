{ config, pkgs, ... }:

{
  services = {
    prometheus = {
      enable = true;
      extraFlags = [ "-log.level=debug" ];
      exporters.blackbox = {
        enable = true;
        configFile = "/etc/prometheus/blackbox.yml";
      };
      scrapeConfigs = [
        {
          job_name ="prometheus";
          scrape_interval = "10s";
          static_configs = [
            {
              targets = [
                "localhost:9090"
              ];
              labels = {
                alias = "home-gp-server";
              };
            }
          ];
        }
        {
          job_name ="ping";
          scrape_interval = "5s";
          metrics_path = "/probe";
          params = {
            module = ["icmp"];
          };
          static_configs = [
            {
              targets = [
                "chromecast"
                "diskstation"
                "gliese"
                "lp-dwhittin-linux"
                "roku"
              ];
              labels = {
                alias = "lan";
              };
            }
          ];
          relabel_configs = [
            {
              source_labels = [ "__address__" ];
              regex = "(.*)(:80)?";
              target_label = "__param_target";
              replacement = "\${1}";
            }
            {
              source_labels = [ "__param_target" ];
              regex = "(.*)";
              target_label = "instance";
              replacement = "\${1}";
            }
            {
              source_labels = [];
              regex = ".*";
              target_label = "__address__";
              replacement = "127.0.0.1:9115";
            }
          ];
        }
      ];
    };
  };
}
