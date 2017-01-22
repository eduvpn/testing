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

echo "Enter the ID range of LXC containers that should be stopped:"
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

# Starting LXC container(s)
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
echo
sleep $TIME

echo
echo "Done!"
echo
echo

