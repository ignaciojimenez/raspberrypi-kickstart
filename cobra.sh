#!/usr/bin/env bash
# 
# Script to kickstart raspbmc and torrent client specific configurations

# set -o errexit
# set -o pipefail
# set -o nounset
# set -o xtrace

echo
echo "------------------------------------------------------"
echo "Beginning Cobra script"
echo "------------------------------------------------------"
echo

cobra_original_ip="192.168.2.203"
cobra_original_user="pi"

echo "------------------------------------------------------"
echo "Modifying apt sources, installing plex and stopping it to migrate library"
echo "------------------------------------------------------"
sudo apt --yes install apt-transport-https
#add plex-server
sudo curl https://downloads.plex.tv/plex-keys/PlexSign.key | sudo apt-key add -
sudo echo deb https://downloads.plex.tv/repo/deb public main | sudo tee /etc/apt/sources.list.d/plexmediaserver.list
sudo apt update
sudo apt --yes install plexmediaserver
sudo systemctl stop plexmediaserver

echo "------------------------------------------------------"
echo "Creating original plex backup, and stopping server, this might take a while"
echo "------------------------------------------------------"
ssh-copy-id ${cobra_original_user}@${cobra_original_ip}
ssh ${cobra_original_user}@${cobra_original_ip} sudo systemctl stop plexmediaserver
ssh ${cobra_original_user}@${cobra_original_ip} sudo tar cfz PlexBackup.tar.gz /var/lib/plexmediaserver/Library
scp ${cobra_original_user}@${cobra_original_ip}:PlexBackup.tar.gz .
echo "------------------------------------------------------"
echo "Backup done and copied to local pi, now cloning old library"
echo "------------------------------------------------------"
sudo rm -rf /var/lib/plexmediaserver/Library
sudo tar -xf PlexBackup.tar.gz --directory /
sudo chown -R plex:plex /var/lib/plexmediaserver/Library

echo "------------------------------------------------------"
echo "Backup restored, installing NTFS drivers and modifying fstab to automount HDD"
echo "------------------------------------------------------"
sudo apt --yes install ntfs-3g
#create mount point for
sudo mkdir /mnt/almacenNTFS
sudo chmod 777 /mnt/almacenNTFS/
#add fstab entry
sudo umount -a
echo "UUID=9E783B49783B1F87 /mnt/almacenNTFS ntfs defaults,auto,umask=000,users,rw,nofail 0 0" | sudo tee -a /etc/fstab > /dev/null
ssh ${cobra_original_user}@${cobra_original_ip} sudo umount -a
echo "Remove HDD from OLD Pi and insert to the new PI. Once it is done, press return"
read
sudo mount -a

echo "------------------------------------------------------"
echo "HDD mounted, starting plex server again. Check in localhost:32400"
echo "------------------------------------------------------"
systemctl start plexmediaserver

echo "------------------------------------------------------"
echo "Installing transmission and importing settings.json from gist"
echo "------------------------------------------------------"
sudo apt --yes install transmission-daemon
sudo systemctl stop transmission-daemon
# creating a copy of the original settings
sudo mv /etc/transmission-daemon/settings.json /etc/transmission-daemon/settings_old.json
sudo curl https://gist.githubusercontent.com/ignaciojimenez/9fe7e751c0f66251868ee60e9d58a7e6/raw/ -o /etc/transmission-daemon/settings.json
sudo chown debian-transmission:debian-transmission /etc/transmission-daemon/settings.json
sudo systemctl start transmission-daemon

echo "------------------------------------------------------"
echo "Installing pip3 feedbarser"
echo "------------------------------------------------------"
# installing python pip
sudo apt --yes install python3-pip
#installing rss parser pip package
pip3 install feedparser

echo "------------------------------------------------------"
echo "Installing pip3 tvnamer"
echo "------------------------------------------------------"
#installing tvnamer pip package
pip3 install tvnamer

echo "------------------------------------------------------"
echo "Cloning cobra git repo"
echo "------------------------------------------------------"
# installing cobra-code command dependencies
sudo apt --yes install unzip git
git config --global user.email "i.jimenezpi@gmail.com"
git config --global user.name "Choco"
#cloning cobra git repo
git clone https://github.com/ignaciojimenez/cobra.git
mv cobra/ .cobra/

echo "------------------------------------------------------"
echo "Creating log and auth folders"
echo "------------------------------------------------------"
#create logs and auth dirs creation
mkdir .cobra/logs
mkdir .cobra/auth

echo "------------------------------------------------------"
echo "Moving auth files"
echo "------------------------------------------------------"
#move auth files
mv *.ini .cobra/auth
sudo chown -R ${USER}:${USER} .cobra/auth

echo "------------------------------------------------------"
echo "Modifying crontab"
echo "------------------------------------------------------"
#install crontab
#echo "$(echo '* 1 * * * some_command' ; crontab -l)" | crontab -
echo "$(echo "05 * * * * /usr/bin/python3 /home/${USER}/.local/bin/tvnamer -q -b -c /home/${USER}/.cobra/mytvnamerconfig.json /mnt/almacenNTFS/Descargas/ready >> /home/${USER}/.cobra/logs/tvnamer.log 2>&1" ; crontab -u ${USER} -l)" | crontab -u ${USER} -
echo "$(echo "03 * * * * /usr/bin/python3 /home/${USER}/.cobra/renamenew.py >> /home/${USER}/.cobra/logs/rename.log 2>&1" ; crontab -u ${USER} -l)" | crontab -u ${USER} -
echo "$(echo "@hourly /bin/bash /home/${USER}/.cobra/zmovetorrent.sh >> /home/${USER}/.cobra/logs/move.log 2>&1" ; crontab -u ${USER} -l)" | crontab -u ${USER} -
echo "$(echo "@hourly /usr/bin/python3 /home/${USER}/.cobra/rss.py >> /home/${USER}/.cobra/logs/rss.log 2>&1" ; crontab -u ${USER} -l)" | crontab -u ${USER} -

echo "------------------------------------------------------"
echo "Instaling samba and modifying samba share configs"
echo "------------------------------------------------------"
# installing samba to access the shared files
sudo apt --yes install samba samba-common-bin
sudo chown -R nobody.nogroup /mnt/almacenNTFS/
sudo chmod -R 777 /mnt/almacenNTFS/
sudo cp /etc/samba/smb.conf /etc/samba/smb.conf.old
echo "[Plex_Storage]" | sudo tee -a /etc/samba/smb.conf > /dev/null
echo "  browseable = yes" | sudo tee -a /etc/samba/smb.conf > /dev/null
echo "  path = /mnt/almacenNTFS" | sudo tee -a /etc/samba/smb.conf > /dev/null
echo "  guest ok = yes" | sudo tee -a /etc/samba/smb.conf > /dev/null
echo "  read only = no" | sudo tee -a /etc/samba/smb.conf > /dev/null
echo "  create mask = 777" | sudo tee -a /etc/samba/smb.conf > /dev/null
sudo systemctl restart smbd
sudo systemctl restart nmbd