#!/bin/bash

LOG_FILE="/var/log/docsclean.log"
#touch "$LOG_FILE"
chmod 666 "$LOG_FILE"
#added v1.1
CLEANED_LOG="/var/log/docsclean_cleaned.log"
#touch "$CLEANED_LOG"
chmod 666 "$CLEANED_LOG"

idProduct=$2    # ATTRS{idProduct}
idVendor=$3     # ATTRS{idVendor}
manufacturer=$4 # ATTRS{manufacturer}
product=$5      # ATTRS{product}
serial=$6       # ATTRS{serial}


if [ ! -z "$serial" ]; then
	if [[ "$1" == "add" ]]; then
        	echo "[$(date +"%T - %d.%m.%y")] : Підключено флеш носій. ID of product is $idProduct , ID of vendor is $idVendor , manufacturer is $manufacturer , product is $product , serial is $serial" >> "$LOG_FILE"
        	#added v1.1
        	echo "[$(date +"%T - %d.%m.%y")] : Підключено флеш носій. ID of product is $idProduct , ID of vendor is $idVendor , manufacturer is $manufacturer , product is $product , serial is $serial" >> "$CLEANED_LOG"
        	
	fi
	
fi
if [[ "$1" == "remove" ]]; then
        echo "[$(date +"%T - %d.%m.%y")] : Флеш носій було вимкнено!" >> "$LOG_FILE"
        #added v1.1
        echo "[$(date +"%T - %d.%m.%y")] : Флеш носій було вимкнено!" >> "$CLEANED_LOG"
fi
