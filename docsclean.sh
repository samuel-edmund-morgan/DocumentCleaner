#!/bin/bash

while :
do

	LOG_FILE="/home/samuel/docsclean.log"
	IFS=$'\n'
	WORK_PATH=$(grep "$(readlink -f /dev/disk/by-id/usb*)" /proc/mounts | cut -d ' ' -f 2 | sed -e "s/\\\040/ /g" )

	# INIT /dev/sd variable. If there is no WORK_PATH so DEVICE SHOULD BE EMPTY
	DEVICE="$(readlink -f /dev/disk/by-id/usb* | sed -n '2p')"
	if [[  "$DEVICE" == "" ]]; then
		DEVICE="$(readlink -f /dev/disk/by-id/usb* | sed -n '1p')"
        fi


	if [[ ! "$DEVICE" == *"/dev/sd"* ]]; then
   		echo "Ніяких флеш носіїв не підключено (або триває пошук флеш носіїв. Пошук може зайняти до 20 секунд). Вставте флеш носій..."
   		sleep 7
   		continue  
	fi

	if [[ "$WORK_PATH" == "" ]]; then
   		echo "ПОМИЛКА: Пристрій в системі існує, але не змонтований!Пристрій $DEVICE. Вихід..."
		sudo umount -l "$DEVICE"
		printf "\nВийміть свій флеш носій зараз...\n\n"
		while :
		do
        		sleep 1
        		DEVICE="$(readlink -f /dev/disk/by-id/usb* | sed -n '2p')"
			if [[  "$DEVICE" == "" ]]; then
                		DEVICE="$(readlink -f /dev/disk/by-id/usb* | sed -n '1p')"
				if [[ ! "$DEVICE" == *"/dev/sd"* ]]; then
                                	break  
                        	fi
        		fi
		done
   	continue
	fi

	find $WORK_PATH -type f -iname "*.docx" > /tmp/docxArray
	find $WORK_PATH -type f -iname "*.doc" > /tmp/docArray
	find $WORK_PATH -type f -iname "*.rtf" > /tmp/rtfArray
	find $WORK_PATH -iname "*.lnk"  > /tmp/linkArray

	IFS=$'\n'
	docx_array=( $(grep -v -e "001.Original_Documents" -e "002.Cleaned_Documents" -e "\/\."  /tmp/docxArray) )
	doc_array=( $(grep -v -e "001.Original_Documents" -e "002.Cleaned_Documents" -e "\/\."  /tmp/docArray) )
	rtf_array=( $(grep -v -e "001.Original_Documents" -e "002.Cleaned_Documents" -e "\/\."  /tmp/rtfArray) )
	readarray -t link_array < /tmp/linkArray

	rm -rf /tmp/docxArray
	rm -rf /tmp/docArray
	rm -rf /tmp/rtfArray
	rm -rf /tmp/linkArray

	#IF array empty -exit
	if [ ! "${#docx_array[@]}" -gt 0 ] && [ ! "${#rtf_array[@]}" -gt 0 ] && [ ! "${#doc_array[@]}" -gt 0 ] && [ ! "${#link_array[@]}" -gt 0 ] ; then
		sudo umount -l "$DEVICE"
		echo "Документи та шкідливі ярлики на флеш носії не знайдено!"
                printf "\nВийміть свій флеш носій зараз...\n\n"
                while :
                do
                        sleep 1
                        DEVICE="$(readlink -f /dev/disk/by-id/usb* | sed -n '2p')"
                        if [[  "$DEVICE" == "" ]]; then
                                DEVICE="$(readlink -f /dev/disk/by-id/usb* | sed -n '1p')"
                                if [[ ! "$DEVICE" == *"/dev/sd"* ]]; then
                                        break  
                                fi
                        fi
                done
	continue
	fi

	printf "\nСканується шлях: $WORK_PATH"

	find $WORK_PATH -iname "*.lnk" -delete
	printf "\n\n##########################################################-LINKS-##########################################################################################\n"
	if [ "${#link_array[@]}" -gt 0 ]; then
               	 	for (( i=0; i<${#link_array[@]}; i++ ))
                	do
                        	echo "+++ Видалення шкідливих ярликів! ${link_array[i]}"
                        	echo "[$(date)] : Ярлик ${link_array[i]} успішно видалено!" >> "$LOG_FILE"
                        	printf "___________________________________________________________________________________________________________________________________________________________\n"
                	done
	else
                        	echo "Шкідливих ярликів не виявлено!"
                        	echo "[$(date)] : Шкідливих ярликів не виявлено!" >> "$LOG_FILE"
	fi



	regex='Target[[:space:]]*=[[:space:]]*[(\")|('"'"')|(\`)](https?|ftp|file):\/\/[-[:alnum:]\+&@#\/%?=~_|.;]*[-[:alnum:]\+&@#\/%=~_|][(\")|('"'"')|(\`)]'
	replace_with='Target=\"\"'
	printf "\n\n##########################################################-DOCX-##########################################################################################\n"
	if [ "${#docx_array[@]}" -gt 0 ]; then
		for (( i=0; i<${#docx_array[@]}; i++ ))
		do
	   		document_fullpath="${docx_array[i]}"
			document_name=$(echo $document_fullpath | sed -e "s/ /_/g" | rev | cut -d/ -f1 | rev)
	   		document_path=$(dirname "${document_fullpath}")
	   		mkdir -p $document_path/002.Cleaned_Documents/
	   		mkdir -p $document_path/001.Original_Documents/
	   		rnd_path=$(mktemp -d "$document_path/002.Cleaned_Documents/$document_name".XXXXXX)
			unzip -q $document_fullpath -d $rnd_path
			mv $document_fullpath $document_path/001.Original_Documents/$document_name
	                if [[ $(egrep  -orl $regex $rnd_path) ]]; then
	                        egrep  -orlZ $regex $rnd_path | xargs -0 sed -i -E "s/$regex/$replace_with/g"
				(cd $rnd_path && zip -q -r ../$document_name .)
	                        echo "+++ Чистка файлу $document_name завершена!"
				echo "[$(date)] : Чистка файлу $document_name завершена!" >> "$LOG_FILE"
	                else
				cp $document_path/001.Original_Documents/$document_name $document_path/002.Cleaned_Documents/$document_name
	                        echo "--- Файл $document_name чистий!"
	                        echo "[$(date)] : Файл $document_name чистий!" >> "$LOG_FILE"
	                fi
	   		rm -rf $rnd_path
			printf "___________________________________________________________________________________________________________________________________________________________\n"
		done
	fi


	regex='(https?|ftp|file):\/\/[-[:alnum:]\+&@#\/%?=~_|.;]*[-[:alnum:]\+&@#\/%=~_|]'
	replace_with='DELETED_LINK'
	printf "\n\n\n##################################################-RTF-####################################################################################################\n"
	if [ "${#rtf_array[@]}" -gt 0 ]; then
	        for (( i=0; i<${#rtf_array[@]}; i++ ))
	        do
	                document_fullpath="${rtf_array[i]}"
	                document_name=$(echo $document_fullpath | sed -e "s/ /_/g" | rev | cut -d/ -f1 | rev)
			document_path=$(dirname "${document_fullpath}")
	                mkdir -p $document_path/002.Cleaned_Documents/
	                mkdir -p $document_path/001.Original_Documents/
	                cp $document_fullpath $document_path/002.Cleaned_Documents/$document_name 
	                mv $document_fullpath $document_path/001.Original_Documents/$document_name
			if [[ $(egrep  -orl $regex $document_path/002.Cleaned_Documents/$document_name) ]]; then
				egrep  -orlZ $regex $document_path/002.Cleaned_Documents/$document_name | xargs -0 sed -i -E "s/$regex/$replace_with/g"
				echo "+++ Чистка файлу $document_name завершена!"
				echo "[$(date)] : Чистка файлу $document_name завершена!" >> "$LOG_FILE"
			else
				cp $document_path/001.Original_Documents/$document_name $document_path/002.Cleaned_Documents/$document_name
	    			echo "--- Файл $document_name чистий!"
	                        echo "[$(date)] : Файл $document_name чистий!" >> "$LOG_FILE"
			fi
			printf "___________________________________________________________________________________________________________________________________________________________\n"
	        done
	fi


	regex='(https?|ftp|file):\/\/[-[:alnum:]\+&@#\/%?=~_|.;]*[-[:alnum:]\+&@#\/%=~_|]'
	replace_with='DELETED_LINK'
	printf "\n\n\n##################################################-DOC-TO-RTF-#############################################################################################\n"
	if [ "${#doc_array[@]}" -gt 0 ]; then
	        for (( i=0; i<${#doc_array[@]}; i++ ))
	        do
			document_fullpath="${doc_array[i]}"
	                #document_name=$(printf "%q" "$document_fullpath" | rev | cut -d/ -f1 | rev)
			document_name=$(echo $document_fullpath | sed -e "s/ /_/g" | rev | cut -d/ -f1 | rev)
	                document_path=$(dirname "${document_fullpath}")
	                mkdir -p $document_path/002.Cleaned_Documents/
	                mkdir -p $document_path/001.Original_Documents/
			mkdir -p $document_path/tmpconvert/
			lowriter --convert-to rtf --outdir "$document_path/tmpconvert/" "$document_fullpath" > /dev/null 
	                mv $document_fullpath $document_path/001.Original_Documents/$document_name
	                if [[ $(egrep  -orl $regex $document_path/tmpconvert/*.rtf) ]]; then
	                        egrep  -orlZ $regex $document_path/tmpconvert/*.rtf | xargs -0 sed -i -E "s/$regex/$replace_with/g"
	                        echo "+++ Конвертація та чистка файлу $document_name успішно завершена!"
				echo "[$(date)] : Конвертація та чистка файлу $document_name успішно завершена!" >> "$LOG_FILE"
	                else
	                        echo "--- Файл $document_name чистий!"
	 			echo "[$(date)] : Конвертація файлу $document_name успішно завершена! Посилань не виявлено!" >> "$LOG_FILE"
	                fi
			cp $document_path/tmpconvert/*.rtf $document_path/002.Cleaned_Documents/${document_name%.*}.rtf
	                rm -rf $document_path/tmpconvert/
			printf "___________________________________________________________________________________________________________________________________________________________\n"
	        done
	fi

		sudo umount -l "$DEVICE"
                printf "\nВийміть свій флеш носій зараз...\n\n"
                while :
                do
                        sleep 1
                        DEVICE="$(readlink -f /dev/disk/by-id/usb* | sed -n '2p')"
                        if [[  "$DEVICE" == "" ]]; then
                                DEVICE="$(readlink -f /dev/disk/by-id/usb* | sed -n '1p')"
                                if [[ ! "$DEVICE" == *"/dev/sd"* ]]; then
                                        break  
                                fi
                        fi
                done

done
