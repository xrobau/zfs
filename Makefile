SHELL=/bin/bash

.PHONY: halp
halp: setup
	@echo "Run 'make zfs' to install, or 'make status' to see stats"

.PHONY: zfs
zfs: setup /etc/modprobe.d/zfs.arcmax.conf /etc/modprobe.d/zfs.defaults.conf kexec


.PHONY: status
status:
	@D="zfs_dirty_data_max l2arc_noprefetch l2arc_trim_ahead l2arc_write_max zfs_vdev_write_gap_limit zfs_txg_timeout zfs_vdev_cache_size"; \
		cd /sys/module/zfs/parameters; \
		for x in $$D; do \
			grep -H . $$x; \
		done

ANSBIN=/usr/bin/ansible-playbook

ANSIBLE_HOST_KEY_CHECKING=False
export ANSIBLE_HOST_KEY_CHECKING

.PHONY: setup
setup: /usr/bin/vim /usr/bin/ping $(ANSBIN)

.PHONY: ansible
ansible /etc/hosts: /etc/ansible.hostname
	$(ANSBIN) localhost.yml -e hostname=$(shell cat /etc/ansible.hostname)

.PHONY: hostname
hostname /etc/ansible.hostname:
	@C=$(shell hostname); echo "Current hostname '$$C'"; read -p "Set hostname (blank to not change): " h; \
		if [ "$$h" ]; then \
			echo $$h > /etc/ansible.hostname; \
		else \
			if [ ! -s /etc/ansible.hostname ]; then \
				hostname > /etc/ansible.hostname; \
			fi; \
		fi

/etc/modprobe.d/zfs.arcmax.conf:
	@echo "If this machine is only going to be used as a fileserver then"
	@echo "all the memory on this machine will be assigned to ZFS apart from"
	@echo "16GB set aside for OS housekeeping (eg, replication, small docker"
	@echo "containers, those sorts of things). If it is going to be used for"
	@echo "other things, ZFS defaults to capping itself at half available"
	@echo "memory, wasting the other half on a file server."
	@read -p "Is this machine only going to be ONLY used as a file server [Yn]? " fsc; \
		R=$$(echo $$fsc | tr '[:upper:]' '[:lower:]' | cut -c1); \
		if [ "$$R" -a "$$R" != "y" ]; then \
			touch $@; \
		else \
			echo "options zfs zfs_arc_max=$$(awk '/MemTotal:/ { print ( $$2 * 1024 )-( 16 * 1024 * 1024 * 1024) } ' /proc/meminfo)" > $@; \
		fi

/etc/modprobe.d/zfs.defaults.conf:
	@echo "options zfs l2arc_noprefetch=0 zfs_dirty_data_max=17179869184 zfs_vdev_cache_size=16777216" > $@
	@echo "options zfs l2arc_trim_ahead=100 zfs_txg_timeout=120 l2arc_write_max=524288000 zfs_vdev_write_gap_limit=0" >> $@

.PHONY: kexec

kexec: /usr/sbin/kexec /etc/systemd/system/systemd-reboot.service.d/override.conf /etc/systemd/system/kexec-load.service

/usr/sbin/kexec:
	apt-get -y install kexec-tools

/etc/systemd/system/systemd-reboot.service.d/override.conf: override.conf
	mkdir -p $(@D)
	cp $< $@
	systemctl daemon-reload

/etc/systemd/system/kexec-load.service:  kexec-load.service
	cp $< $@
	systemctl enable kexec-load
	systemctl start kexec-load
	systemctl daemon-reload

$(ANSBIN): | /usr/bin/apt-get
	apt-get -y install ansible

ansible-collections: $(ANSBIN) ~/.ansible/collections/ansible_collections/community/general ~/.ansible/collections/ansible_collections/vyos/vyos ~/.ansible/collections/ansible_collections/vyos/vyos/MANIFEST.json ~/.ansible/collections/ansible_collections/ansible/posix/MANIFEST.json ~/.ansible/collections/ansible_collections/community/docker/MANIFEST.json ~/.ansible/collections/ansible_collections/community/mysql/MANIFEST.json

~/.ansible/collections/ansible_collections/ansible/posix/MANIFEST.json:
	ansible-galaxy collection install ansible.posix

~/.ansible/collections/ansible_collections/vyos/vyos/MANIFEST.json:
	ansible-galaxy collection install vyos.vyos

~/.ansible/collections/ansible_collections/community/docker/MANIFEST.json:
	ansible-galaxy collection install community.docker

~/.ansible/collections/ansible_collections/community/mysql/MANIFEST.json:
	ansible-galaxy collection install community.mysql

~/.ansible/collections/ansible_collections/community/general:
	@ansible-galaxy collection install community.general

~/.ansible/collections/ansible_collections/vyos/vyos:
	@ansible-galaxy collection install vyos.vyos

/usr/bin/wget: | /usr/bin/apt-get
	apt-get -y install wget

/usr/bin/unzip: | /usr/bin/apt-get
	apt-get -y install unzip

/usr/bin/vim: | /usr/bin/apt-get
	apt-get -y install vim

/usr/bin/ping: | /usr/bin/apt-get
	apt-get -y install iputils-ping

/usr/bin/apt-get:
	@echo "This only works on ubuntu, with /usr/bin/apt-get. Sorry"
	@exit 1
