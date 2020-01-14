## Description
This raspberry pi will contain a [pihole](https://pi-hole.net/) dns blackholing device which will act as the local dns server, dhcp server, and that will act as the default gateway for devices in the local network and route their traffic through a protonvpn tunnel

## Required files
It is expected for this script to work that the following files are available in the user home folder:
```
pvpnpass
```
## TODO
- [x] ~~Modify setupVars.conf to change default gateway to its own IP when copying it~~ (Not tested IRL yet)
