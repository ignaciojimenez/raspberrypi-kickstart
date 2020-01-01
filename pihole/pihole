#!/bin/bash
# 
# Script to kickstart pihole specific configurations

echo
echo "------------------------------------------------------"
echo "Beginning Pihole script"
echo "------------------------------------------------------"
echo

pihole_original_ip="192.168.2.200"
pihole_original_user="pi"

echo "------------------------------------------------------"
echo "Copying original pihole settings"
echo "------------------------------------------------------"
# copying all the pihole configs
# copying the ssh public key
ssh-copy-id ${pihole_original_user}@${pihole_original_ip}
scp -r ${pihole_original_user}@${pihole_original_ip}:/etc/dnsmasq.d/ .
scp ${pihole_original_user}@${pihole_original_ip}:/etc/pihole/setupVars.conf .
scp ${pihole_original_user}@${pihole_original_ip}:/etc/pihole/adlists.list .
scp ${pihole_original_user}@${pihole_original_ip}:/etc/pihole/whitelist.txt .
scp ${pihole_original_user}@${pihole_original_ip}:/etc/pihole/blacklist.txt .
scp ${pihole_original_user}@${pihole_original_ip}:/etc/pihole/wildcardblocking.txt .
sudo mkdir /etc/pihole
sudo mv -f *.txt /etc/pihole/
sudo mv -f adlists.list /etc/pihole/
sudo mv -f setupVars.conf /etc/pihole/
sudo cp -r dnsmasq.d/* /etc/dnsmasq.d/
sudo rm -rf dnsmasq.d/

echo "------------------------------------------------------"
echo "Installing pihole"
echo "------------------------------------------------------"
#install pihole
curl -L https://install.pi-hole.net | sudo bash /dev/stdin --unattended


echo "------------------------------------------------------"
echo "Installing openvpn and configuring it from gist conf"
echo "------------------------------------------------------"
#installing needed packages for the vpn tunnel and gateway
sudo apt --yes install openvpn
# getting the conf from the gist
sudo wget "https://gist.githubusercontent.com/ignaciojimenez/735d3d9d76cedb4722ae35166563b800/raw/" -O "/etc/openvpn/pvpn.conf"
# Moving login info to etc
sudo mv pvpnpass /etc/openvpn/
# Protect the vpn login info
sudo chmod 400 /etc/openvpn/pvpnpass
# Making openvpn to Autostart
sudo sed -i 's/#AUTOSTART="all"/AUTOSTART="all"/' /etc/default/openvpn
# Registering te service
sudo systemctl enable openvpn@pvpn.service
# Reloading services
sudo systemctl daemon-reload
# Starting the service for the first time
sudo service openvpn@pvpn start
# Testing that the vpn is properly connected
echo "Testing the VPN configuration"
sleep 5
curl ifconfig.co

echo "------------------------------------------------------"
echo "Modifying configs to allow the pihole to act as a router"
echo "------------------------------------------------------"
#Enabling IP forwarding
echo "Enabling IP Routing by uncommenting /etc/sysctl.conf"
sudo sed -i 's/#net.ipv4.ip_forward=1/net.ipv4.ip_forward=1/' /etc/sysctl.conf
#installing iptables persistent and avoiding providing input
echo iptables-persistent iptables-persistent/autosave_v4 boolean true | sudo debconf-set-selections
echo iptables-persistent iptables-persistent/autosave_v6 boolean true | sudo debconf-set-selections
sudo apt-get --yes --force-yes install iptables-persistent
# Setting NATMASQ in TUN0 for traffic forwarding
sudo iptables -t nat -A POSTROUTING -o tun0 -j MASQUERADE
# Allowing related and established connections fron TUN0 to ETH0
sudo iptables -A FORWARD -i tun0 -o eth0 -m state --state RELATED,ESTABLISHED -j ACCEPT
# TODO bypass VPN for specific IPs
#sudo iptables -A FORWARD -s 192.168.2.202 -o eth0 -j ACCEPT
# Forward all traffic from ETH0 to TUN0
sudo iptables -A FORWARD -i eth0 -o tun0 -j ACCEPT

#Pending review Killswitch ideas?

echo "------------------------------------------------------"
echo "Saving newly created iptables"
echo "------------------------------------------------------"
#Making iptables persistent
sudo netfilter-persistent save
sudo systemctl enable netfilter-persistent