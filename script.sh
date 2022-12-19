#!/bin/bash

find /home/samuel/Documents/ -type f -iname "*.docx" > /tmp/docxArray
find /home/samuel/Documents/ -type f -iname "*.doc" > /tmp/docArray
find /home/samuel/Documents/ -type f -iname "*.rtf" > /tmp/rtfArray


IFS=$'\n'
docx_array=( $(grep -v -e "001.Original_Documents" -e "002.Cleaned_Documents"  /tmp/docxArray) )
doc_array=( $(grep -v -e "001.Original_Documents" -e "002.Cleaned_Documents"  /tmp/docArray) )
rtf_array=( $(grep -v -e "001.Original_Documents" -e "002.Cleaned_Documents"  /tmp/rtfArray) )


rm -rf /tmp/docxArray
rm -rf /tmp/docArray
rm -rf /tmp/rtfArray


regex='Target[[:space:]]*=[[:space:]]*[(\")|('"'"')|(\`)](https?|ftp|file):\/\/[-[:alnum:]\+&@#\/%?=~_|.;]*[-[:alnum:]\+&@#\/%=~_|][(\")|('"'"')|(\`)]'
replace_with='Target=\"\"'

if [ "${#docx_array[@]}" -gt 0 ]; then
	for (( i=0; i<${#docx_array[@]}; i++ ))
	do
   		document_fullpath="${docx_array[i]}"
   		document_name=$(printf "%q" "$document_fullpath" | rev | cut -d/ -f1 | rev)
   		document_path=$(dirname "${document_fullpath}")
   		mkdir -p $document_path/002.Cleaned_Documents/
   		mkdir -p $document_path/001.Original_Documents/
   		rnd_path=$(mktemp -d "$document_path/002.Cleaned_Documents/$document_name".XXXXXX)
   		unzip $document_fullpath -d $rnd_path
   		mv $document_fullpath $document_path/001.Original_Documents/$document_name
   		egrep  -orlZ $regex $rnd_path | xargs -0 sed -i -E "s/$regex/$replace_with/g"
   		(cd $rnd_path && zip -r ../$document_name .)
   		rm -rf $rnd_path
		echo "_______________________________________________________________________________________________________________________________________"

	done
echo "#########################################################################################################################################################################"
fi


regex='(https?|ftp|file):\/\/[-[:alnum:]\+&@#\/%?=~_|.;]*[-[:alnum:]\+&@#\/%=~_|]'
replace_with='DELETED_LINK'

if [ "${#rtf_array[@]}" -gt 0 ]; then
        for (( i=0; i<${#rtf_array[@]}; i++ ))
        do
                document_fullpath="${rtf_array[i]}"
                document_name=$(printf "%q" "$document_fullpath" | rev | cut -d/ -f1 | rev)
                document_path=$(dirname "${document_fullpath}")
                mkdir -p $document_path/002.Cleaned_Documents/
                mkdir -p $document_path/001.Original_Documents/
                cp $document_fullpath $document_path/002.Cleaned_Documents/$document_name 
                mv $document_fullpath $document_path/001.Original_Documents/$document_name
                egrep  -orlZ $regex $document_path/002.Cleaned_Documents/$document_name | xargs -0 sed -i -E "s/$regex/$replace_with/g"
		echo "Cleaning of file $document_name have been completed!"
		echo "_______________________________________________________________________________________________________________________________________"
        done
echo "########################################################################################################################################################################"
fi



#egrep  -orlZ '(https?|ftp|file):\/\/[-[:alnum:]\+&@#\/%?=~_|.;]*[-[:alnum:]\+&@#\/%=~_|]' /home/samuel/Documents/1
#if [ "${#rtf_array[@]}" -gt 0 ]; then
#        for (( i=0; i<${#rtf_array[@]}; i++ ))
#        do
#                document_fullpath="${rtf_array[i]}"
#                document_name=$(printf "%q" "$document_fullpath" | rev | cut -d/ -f1 | rev)
#                document_path=$(dirname "${document_fullpath}")
#                mkdir -p $document_path/002.Cleaned_Documents/
#                mkdir -p $document_path/001.Original_Documents/
#                #rnd_path=$(mktemp -d "$document_path/002.Cleaned_Documents/$document_name".XXXXXX)
#                #unzip $document_fullpath -d $rnd_path
#                mv $document_fullpath $document_path/001.Original_Documents/$document_name
#                egrep  -orlZ $regex $rnd_path | xargs -0 sed -i -E "s/$regex/$replace_with/g"
#                (cd $rnd_path && zip -r ../$document_name .)
#                rm -rf $rnd_path
#        done
#fi
