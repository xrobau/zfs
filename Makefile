SHELL=/bin/bash

# Allow xrobau, he's a nice guy. "Honest" Rob.
SSHKEYS=xrobau

# Base prep here
TMPDIR=$(HOME)/.zfstmp
GROUPVARS=$(shell pwd)/group_vars

ANSIBLE_HOST_KEY_CHECKING=False
export ANSIBLE_HOST_KEY_CHECKING

# Anything here can be automatically made by the $(MKDIRS) target below
MKDIRS=$(TMPDIR) $(GROUPVARS) $(GROUPVARS)/all

# Things that are always needed
TOOLS += curl vim ping wget netstat ansible-playbook
PKG_ping=iputils-ping
PKG_netstat=net-tools
PKG_ansible-playbook=ansible

# This is first so we always have a default that is harmless (assuming
# you think that 'make setup' is harmless, which I think it is!)
.PHONY: halp
halp: setup
	@echo "Run 'make zfs' to install, or 'make status' to see stats"


# Drag in any includes
include $(wildcard includes/Makefile.*)

# This is anything that's in TOOLS or STOOLS
PKGS=$(addprefix /usr/bin/,$(TOOLS))
SPKGS=$(addprefix /usr/sbin/,$(STOOLS))

STARGETS += $(PKGS) $(SPKGS)

# And now trigger them
.PHONY: setup
setup: $(STARGETS)

.PHONY: debug
debug:
	@echo "I want to trigger $(STARGETS) in setup"

# This installs whatever's needed
/usr/bin/% /usr/sbin/%:
	p="$(PKG_$*)"; p=$${p:=$*}; apt-get -y install $$p || ( echo "Don't know how to install $*, fix the makefile"; exit 1 )

# Just make anything in MKDIRS, easy DRY.
$(MKDIRS):
	mkdir -p $@

