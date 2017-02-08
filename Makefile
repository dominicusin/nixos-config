.PHONY: switch sync

local_config:=$(shell hostname -s).nix

switch: sync
	sudo nixos-rebuild switch

sync:
	sudo rsync -r ./ /etc/nixos/
	sudo ln -sf /etc/nixos/machines/$(local_config) /etc/nixos/configuration.nix
