#!/bin/bash

#Skip dir with names
find /home/samuel/Documents/ -type f -iname "*.docx" > /home/samuel/allDocx
IFS=$'\n'
docx_array=( $(grep -v -e "001.Original_Documents" -e "002.Cleaned_Documents"  /home/samuel/allDocx) )






IFS=$'\n'
docx_array=( $(find /home/samuel/Documents/ -type f -iname "*.docx") )
regex='Target[[:space:]]*=[[:space:]]*[(\")|('"'"')|(\`)](https?|ftp|file):\/\/[-[:alnum:]\+&@#\/%?=~_|.;]*[-[:alnum:]\+&@#\/%=~_|][(\")|('"'"')(\`)]'
replace_with='Target=\"\"'
if [ "${#docx_array[@]}" -le 0 ]; then
	echo "DOCX not found"
	exit 1
fi
for (( i=0; i<${#docx_array[@]}; i++ ))
do
   document_fullpath="${docx_array[i]}"
   document_name=$(printf "%q" "$document_fullpath" | rev | cut -d/ -f1 | rev)
   document_path=$(dirname "${document_fullpath}")
   mkdir -p $document_path/cleaned/
   rnd_path=$(mktemp -d "$document_path/cleaned/$document_name".XXXXXX)
   unzip $document_fullpath -d $rnd_path
   egrep  -orlZ $regex $rnd_path | xargs -0 sed -i -E "s/$regex/$replace_with/g"
   (cd $rnd_path && zip -r ../$document_name .)
   rm -rf $rnd_path
done
