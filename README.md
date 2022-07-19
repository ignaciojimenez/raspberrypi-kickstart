# Raspberrypi-kickstart

## Deprecation
This repo has been deprecated in favour of https://github.com/ignaciojimenez/raspberrypi-ansible due to lack of maintenance of the base project https://github.com/FooDeas/raspberrypi-ua-netinst

## Description
This is a collection of scripts to kickstart raspberry pi's using a minimal raspbian installation based on https://github.com/FooDeas/raspberrypi-ua-netinst
## Usage
This repo has multiple tools. Use at suited.
### Pre-bootup
- `load_pri raspbian|[download_url]`: MacOS tool to load a base image to an SD card
- `bootstrap_rpi [flavour]`: Tool to load raspbian-netinst configuration specific for the flavour
### Post-bootup
- `kickstart`: (not expected to be used by a human-user) Small tool that downloads this repo and executes the installation using the hostname as input for `installation`
- `installation [flavour]`: Tool to install the defined flavour specifics (requires all repo folders to work)
## TODO
- [ ] Store and retrieve secrets from bitwarden
- [ ] Review TODOs for the different flavours
