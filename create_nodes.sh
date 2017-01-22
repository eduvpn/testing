#!/bin/bash

#############################################################################
# Version 1.0.0-alpha.1 (22-01-2017)
#############################################################################

#############################################################################
# Copyright 2016 Sebas Veeke. Released under the GPLv3 license
#############################################################################


#############################################################################
# USER VARIABLES
#############################################################################

# HARDWARE SETTINGS
CORES='1'                                       # Number of vCPU cores
MEMORY='512'					# Amount of RAM in MB
DISKSIZE='4'					# Disksize in GB

# VIRTUAL MACHINE SETTINGS
IMAGE='/var/lib/vz/template/cache/debian-8.0-standard_8.6-1_amd64.tar.gz'

# OPERATING SYSTEM SETTINGS
USERNAME='seve'					# Username
PASSWORD='password'			        # Password for user and root account

# NETWORK SETTINGS
IPFROM='10.1.2'					# First three octets of IP-range (e.g. 192.168.1)
SUBNET='/16'					# Use CIDR format (e.g. /16)
GATEWAY='10.1.0.1'			        # Router gateway (e.g. 192.168.0.1)
DNS='84.200.69.80'			        # Define DNS nameserver (e.g. 84.200.69.80)
BRIDGE='vmbr1'					# Bridge name in host (e.g. vmbr0)
INTERFACE='eth0'				# Interface name (e.g. eth0)


#############################################################################
# USER INPUT
#############################################################################

echo "Enter the ID range of containers that should be created:"
echo
read -p "$(echo "ID range from:   ")" FROM
read -p "$(echo "ID range to:     ")" TO


#############################################################################
# SYSTEM VARIABLES
#############################################################################

TIME=$(expr $TO - $FROM + 5)


#############################################################################
# CREATE AND CONFIGURE CONTAINERS
#############################################################################

# Create new containers
echo
echo
echo "CREATING CONTAINERS..."
for ((i=FROM; i<=TO; i++))
    do
        echo "Create container with ID $i"
        pct create $i $IMAGE &
		sleep 1
    done

echo
echo "Giving the host some time..."
wait
sleep $TIME

# Configure new containers
echo
echo
echo "CONFIGURE CONTAINERS..."
for ((i=FROM; i<=TO; i++))
    do
        echo "Configure container with ID $i"
		IP="$IPFROM.$i"
        pct set $i -cores $CORES -memory $MEMORY -nameserver $DNS -net0 name=$INTERFACE,bridge=$BRIDGE,ip=$IP$SUBNET,gw=$GATEWAY &
    done

echo
echo "Giving the host some time..."
wait
sleep 5

# Start new containers
echo
echo
echo "STARTING CONTAINERS..."
for ((i=FROM; i<=TO; i++))
    do
        echo "Start container with ID $i"
        pct start $i &
    done

echo
echo "Giving the host some time..."
wait
sleep $TIME


#############################################################################
# CONFIGURE CONTAINER AND HOST
#############################################################################

# Hashing the password
HASH=$(openssl passwd -1 -salt temp $PASSWORD)

# Create the user account with chosen password 
echo
echo
echo "CREATING USER ACCOUNTS..."
for ((i=FROM; i<=TO; i++))
    do
        echo "Create user account on container with ID $i"
        lxc-attach -n $i -- useradd $USERNAME -s /bin/bash -m -U -p $HASH
		lxc-attach -n $i -- usermod --password $HASH root
    done

echo
echo "Giving the host some time..."
sleep 3

# Change sshd_config to insecure version
echo
echo
echo "CHANGING SSHD_CONFIG..."
for ((i=FROM; i<=TO; i++))
    do
	    echo
        echo "Change sshd_config on container with ID $i"
        lxc-attach -n $i -- wget -q http10.1.2.118/insecure-sshd_config -O /etc/ssh/sshd_config --no-check-certificate
		lxc-attach -n $i -- service ssh restart
    done

echo
echo "Giving the host some time..."
sleep 3

# Create TUN interface in container
echo
echo
echo "CREATING TUN INTERFACES..."
for ((i=FROM; i<=TO; i++))
    do
        echo "Create TUN interface in container with ID $i"
        lxc-attach -n $i -- mkdir /dev/net
        lxc-attach -n $i -- mknod /dev/net/tun c 10 200
        lxc-attach -n $i -- chmod 0666 /dev/net/tun
    done
	
echo
echo "Giving the host some time..."
wait
sleep 3

# Allow TUN device in host
echo
echo
echo "ALLOW TUN DEVICE IN HOST..."
for ((i=FROM; i<=TO; i++))
do
echo "Allow TUN device for container with ID $i"
cat << EOF >> /var/lib/lxc/$i/config

# Allow Tun Device
lxc.cgroup.devices.allow = c 10:200 rwm

# Run an autodev hook to setup the device
lxc.autodev = 1
lxc.hook.autodev = /var/lib/lxc/$i/autodev
lxc.pts = 1024
lxc.kmsg = 0
EOF
done

echo
echo "Giving the host some time..."
wait
sleep 3

# Push openVPN config to container
echo
echo
echo "DOWNLOADING OpenVPN configuration..."
for ((i=FROM; i<=TO; i++))
    do
        echo "Download OpenVPN config on container with ID $i"
        lxc-attach -n $i -- mkdir /home/$USERNAME/config
		lxc-attach -n $i -- wget -q 10.1.2.118/$i.ovpn -O /home/seve/config/$i.ovpn
    done

echo
echo
echo "done!"
echo
