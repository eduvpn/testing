#!/bin/bash

#############################################################################
# Version 1.0.0-alpha.1 (22-01-2017)
#############################################################################

#############################################################################
# Copyright 2016 Sebas Veeke. Released under the AGPLv3 license
#############################################################################

#############################################################################
# USER VARIABLES
#############################################################################

BEARER=''
SAVEDIR='/var/www/html'


#############################################################################
# USER INPUT
#############################################################################

echo "Enter the range of configuration files that should be created:"
echo
read -p "$(echo "ID range from:   ")" FROM
read -p "$(echo "ID range to:     ")" TO


#############################################################################
# DOWNLOAD CONFIGURATION FILES
#############################################################################

echo
echo
echo "DOWNLOADING CONFIGURATION FILES..."
for ((i=FROM; i<=TO; i++))
    do
        echo "Downloading configuration file $i"
        curl -H "Authorization: Bearer $BEARER" \
        -d "display_name=$i&profile_id=internet" \
	-o $SAVEDIR/$i.ovpn \
        https://labrat.eduvpn.nl/portal/api.php/create_config
    done

echo
echo
echo "AMENDING CONFIGURATION FILES..."
for ((i=FROM; i<=TO; i++))
do
echo "Amending configuration file $i"
cat << EOF >> $SAVEDIR/$i.ovpn

daemon
EOF
done

echo
echo
echo "Done!"
