.PHONY: switch sync

switch: sync
	sudo nixos-rebuild switch

sync:
	sudo rsync -r ./ /etc/nixos/
