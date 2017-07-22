.PHONY: switch sync

local_config:=$(shell hostname -s).nix

switch: sync
	sudo nixos-rebuild switch

sync:
	sudo rsync -r ./ /etc/nixos/
	sudo ln -sf /etc/nixos/machines/$(local_config) /etc/nixos/configuration.nix

sync-remote:
	rsync -r ./ root@ec2-gp-server:/etc/nixos/
	ssh root@ec2-gp-server ln -sf /etc/nixos/machines/ec2-gp-server.nix /etc/nixos/configuration.nix
	rsync -r ./ root@memocorder-prod:/etc/nixos/
	ssh root@memocorder-prod ln -sf /etc/nixos/machines/memocorder-prod.nix /etc/nixos/configuration.nix
	rsync -r ./ root@home-gp-server:/etc/nixos/
	ssh root@home-gp-server ln -sf /etc/nixos/machines/home-gp-server.nix /etc/nixos/configuration.nix

switch-remote: sync-remote
	ssh root@ec2-gp-server nixos-rebuild switch
	ssh root@memocorder-prod nixos-rebuild switch
	ssh root@home-gp-server nixos-rebuild switch
