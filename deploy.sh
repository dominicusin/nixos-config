#!/usr/bin/env bash

set -e

script_dir=$(readlink -f $(dirname "${BASH_SOURCE[0]}"))

remote_hosts="home-gp-server"

usage() {
  echo "Usage"
}

while getopts "hsr:R" opt; do
  case "$opt" in
    h)
      usage
      exit 0
      ;;
    s)
      sync_only=true
      ;;
    r)
      sync_remote=true
      remote_hosts="$OPTARG"
      ;;
    R)
      sync_remote=true
      ;;
  esac
done

if [ -z "$sync_remote" ]; then
  echo "Syncing local configuration..."
  $HOME/Work/vs/lono-nixos-config/sync.sh

  if [ -z "$sync_only" ]; then
    echo "Switching local configuration..."
    sudo nixos-rebuild switch --upgrade
  fi
fi

if [ "$sync_remote" = true ]; then
  for host in "$remote_hosts"; do
    echo "Syncing configuration for ${host}..."
    rsync -v -r --include='*.nix' --include='*/' --exclude='*' \
          "${script_dir}/" "root@${host}:/etc/nixos/"
    if [ -z "$sync_only" ]; then
      echo "Switching configuration on ${host}..."
      ssh "root@${host}" 'bash -c "ln -sf /etc/nixos/machines/$(hostname -s).nix /etc/nixos/configuration.nix"'
      ssh "root@${host}" nixos-rebuild switch
    fi
  done
fi
