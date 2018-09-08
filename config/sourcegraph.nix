{ config, pkgs, ... }:

{
  systemd.services.sourcegraph = {
    description = "sourcegraph";
    wantedBy = [ "multi-user.target" ];
    after = [ "docker.service" ];
    serviceConfig = {
      ExecStart = ''
        ${pkgs.docker}/bin/docker run \
          -p 7080:7080 --rm --name sourcegraph \
          -v /opt/sourcegraph/config:/etc/sourcegraph \
          -v /opt/sourcegraph/data:/var/opt/sourcegraph \
          -v /var/run/docker.sock:/var/run/docker.sock \
          sourcegraph/server:2.7.6
      '';
    };
  };
}
