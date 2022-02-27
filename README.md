# Automatic ZFS File Server

This creates a ZFS fileserver, with all configuration settings
and tunings applied.

# Instructions

1. Speak to xrobau

## Alternative Instructions

If you can't find a local xrobau to assist you, try this:

```
make setup
make zfs
make ansible
```

# FAQ

## Couldn't those three commands be just one?

Yes.

## What does those commands do?

They do stuff. Stuff and things. Read the Makefile and playbooks for
more informaiton.

## Does this work on real hardware?

That's what it's made for. That's why the motd has the IPMI address
of the device in it (if it has one)

## Does this work on VMs?

Yes, but it won't have an IPMI address.

## Who do I blame when it doesn't work?

Anyone apart from xrobau.

