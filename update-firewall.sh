#!/bin/bash

source /opt/vyatta/etc/functions/script-template
configure

for domain_fw_pair in "$@"
do
    DOMAIN="$(echo $domain_fw_pair | cut -d':' -f1)"
    FW_GROUP="$(echo $domain_fw_pair | cut -d':' -f2)"
    echo "Update firewall group $FW_GROUP with new IP(s) for domain $DOMAIN"
    IPS=($(host -4 $DOMAIN -t A | grep "has IPv4 address" | sed 's/.*has IPv4 ad                                                    dress //g'))
    if [ ${#IPS[@]} ]
    then
        delete firewall group address-group $FW_GROUP address
        for IP in "${IPS[@]}"
        do
            echo "Adding $DOMAIN $IP to firewall group $FW_GROUP"
            set firewall group address-group $FW_GROUP address $IP
        done
    else
        echo "Could not get IP for $DOMAIN"
    fi
done

commit && save && exit