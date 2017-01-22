#!/bin/bash

#############################################################################
# Version 1.0.0-alpha.1 (22-01-2017)
#############################################################################

#############################################################################
# Copyright 2016 Sebas Veeke. Released under the GPLv3 license
#############################################################################


#############################################################################
# USER INPUT
#############################################################################

echo "Enter the ID range of containers that should be destroyed:"
echo
read -p "$(echo "ID range from:   ")" FROM
read -p "$(echo "ID range to:     ")" TO


#############################################################################
# VARIABLES
#############################################################################

TIME=$(expr $TO - $FROM + 5)


#############################################################################
# DELETE NODES
#############################################################################

# Stopping LXC container(s)
echo
echo
echo "STOPPING CONTAINERS..."
for ((i=FROM; i<=TO; i++))
    do
        echo "Stop container ID $i"
        pct stop $i &
    done

echo
echo "Giving the host some time..."
sleep $TIME

# Destroying LXC containers
echo
echo "DESTROYING CONTAINERS..."
for ((i=FROM; i<=TO; i++))
    do
        echo "Destroying LXC container $i"
        pct destroy $i &
    done

echo
echo "Giving the host some more time..."
sleep $TIME

echo
echo "Done!"
echo
echo
