#!/bin/bash

#############################################################################
# Version 1.0.0-alpha.1 (20-01-2017)
#############################################################################

#############################################################################
# Copyright 2016 Sebas Veeke. Released under the GPLv3 license
#############################################################################


#############################################################################
# VARIABLES
#############################################################################

# VM SETTINGS
#VMID='120'						  # VM ID on host

# NETWORK SETTINGS
IPFROM='10.1.2'					# First three octets
SUBNET='/16'					  # Use CIDR format
GATEWAY='10.1.0.1'			# Router gateway
DNS='84.200.69.80'			# Define DNS nameserver or leave empty for host default
BRIDGE='vmbr1'					# Bridge name in host, i.e. vmbr0
INTERFACE='eth0'				# Interface name, i.e. eth0

# HARDWARE SETTINGS
CORES='1'						    # Number of vCPU cores
MEMORY='512'					  # Amount of RAM in MB
DISKSIZE='4'					  # Disksize in GB

# OS SETTINGS
IMAGE='/var/lib/vz/template/cache/debian-8.0-standard_8.6-1_amd64.tar.gz'
USERNAME='seve'					# Username
PASSWORD=''			        # Password for user and root account


#############################################################################
# USER INPUT
#############################################################################

# Read VMID
read -p "$(echo -e "Enter VM ID:         		")" VMID


#############################################################################
# CREATE CONTAINER
#############################################################################

IP="$IPFROM.$VMID"
pct create $VMID $IMAGE
pct set $VMID -cores $CORES -memory $MEMORY -nameserver $DNS -net0 name=$INTERFACE,bridge=$BRIDGE,ip=$IP$SUBNET,gw=$GATEWAY
pct start $VMID

sleep 7


#############################################################################
# CONFIGURE CONTAINER AND HOST
#############################################################################

# Hashing the password
HASH=$(openssl passwd -1 -salt temp $PASSWORD)

# Create the user account with chosen password 
lxc-attach -n $VMID -- useradd $USERNAME -s /bin/bash -m -U -p $HASH

# Change root password
lxc-attach -n $VMID -- usermod --password $HASH root

# Update operating system
lxc-attach -n $VMID -- apt update
lxc-attach -n $VMID -- apt -y upgrade

# Install software
lxc-attach -n $VMID -- apt -y install ca-certificates openvpn curl rsync

# Changing sshd_config to insecure version (do not use on publically accessible servers!)
lxc-attach -n $VMID -- wget https://raw.githubusercontent.com/sveeke/jumble/master/generic/insecure-sshd_config -O /etc/ssh/sshd_config --no-check-certificate
lxc-attach -n $VMID -- service ssh restart

# Create TUN interface in container
lxc-attach -n $VMID -- mkdir /dev/net
lxc-attach -n $VMID -- mknod /dev/net/tun c 10 200
lxc-attach -n $VMID -- chmod 0666 /dev/net/tun

# Allow TUN device in host
cat << EOF >> /var/lib/lxc/$VMID/config

# Allow Tun Device
lxc.cgroup.devices.allow = c 10:200 rwm

# Run an autodev hook to setup the device
lxc.autodev = 1
lxc.hook.autodev = /var/lib/lxc/$VMID/autodev
lxc.pts = 1024
lxc.kmsg = 0
EOF

# Push openvpn config file to container
lxc-attach -n $VMID -- mkdir /home/seve/config
lxc-attach -n $VMID -- wget 10.1.2.118/$VMID.ovpn -O /home/seve/config/$VMID.ovpn

# Push CURL script to container
lxc-attach -n $VMID -- mkdir /home/seve/scripts
lxc-attach -n $VMID -- wget 10.1.2.118/curl.sh -O /home/seve/scripts/curl.sh
lxc-attach -n $VMID -- chmod 700 /home/seve/scripts/curl.sh

# Running Webtest
lxc-attach -n $VMID -- openvpn /home/seve/config/$VMID.ovpn
sleep 20
lxc-attach -n $VMID -- ./home/seve/scripts/curl.sh
