{ config, pkgs, ... }:

{
  systemd.services.sourcegraph = {
    description = "sourcegraph";
    after = [ "network.target" ];
    serviceConfig = {
      ExecStart = ''
        ${pkgs.docker}/bin/docker run \
          -p 7080:7080 --rm \
          -v /opt/sourcegraph/config:/etc/sourcegraph \
          -v /opt/sourcegraph/data:/var/opt/sourcegraph \
          -v /var/run/docker.sock:/var/run/docker.sock \
          sourcegraph/server:2.7.6
      '';
    };
  };
}
