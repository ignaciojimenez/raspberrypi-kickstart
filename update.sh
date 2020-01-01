#!/usr/bin/env bash
# 
# Script to update periodically the pi

echo [$(date)] " update started"
sudo apt --yes update && sudo apt --yes upgrade && sudo apt --yes full-upgrade
sudo apt --yes autoremove
sudo apt-get --yes autoclean
sudo reboot