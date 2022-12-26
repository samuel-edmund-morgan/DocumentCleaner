#!/bin/bash

LOG_FILE="/var/log/docsclean.log"
touch "$LOG_FILE"
chmod 666 "$LOG_FILE"

idProduct=$2    # ATTRS{idProduct}
idVendor=$3     # ATTRS{idVendor}
manufacturer=$4 # ATTRS{manufacturer}
product=$5      # ATTRS{product}
serial=$6       # ATTRS{serial}


if [ ! -z "$serial" ]; then
	if [[ "$1" == "add" ]]; then
        	echo "[$(date +"%T - %d.%m.%y")] : Підключено флеш носій. ID of product is $idProduct , ID of vendor is $idVendor , manufacturer is $manufacturer , product is $product , serial is $serial" >> "$LOG_FILE"
	fi
	
fi
if [[ "$1" == "remove" ]]; then
        echo "[$(date +"%T - %d.%m.%y")] : Флеш носій було вимкнено!" >> "$LOG_FILE"
fi
