{ config, pkgs, ... }:

{
  systemd.services.prometheus = {
    description = "prometheus";
    after = [ "network.target" ];
    serviceConfig = {
      ExecStart = ''
        ${pkgs.docker}/bin/docker run \
          --rm --network host \
          -v /opt/prometheus/etc:/etc/prometheus \
          -v /opt/prometheus/data:/prometheus \
          prom/prometheus:v2.2.1
      '';
    };
  };

  systemd.services.node-exporter = {
    description = "node-exporter";
    after = [ "network.target" ];
    serviceConfig = {
      ExecStart = ''
        ${pkgs.docker}/bin/docker run \
          --rm --network host \
          -v /proc:/host/proc:ro \
          -v /sys:/host/sys:ro \
          -v /:/rootfs:ro \
          prom/node-exporter \
          --path.procfs=/host/proc \
          --path.sysfs=/host/sys \
          --collector.filesystem.ignored-mount-points \
          "^/(sys|proc|dev|host|etc|rootfs/var/lib/docker/containers|rootfs/var/lib/docker/overlay2|rootfs/run/docker/netns|rootfs/var/lib/docker/aufs)($$|/)"
      '';
    };
  };
}
