.PHONY: switch sync

switch: sync
	sudo nixos-rebuild switch

sync:
	sudo rsync -r ./ /etc/nixos/
	sudo chmod -R 600 /etc/nixos
