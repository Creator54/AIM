#!/bin/bash

f1="/media/iso"
f2="output"
sys="$f2/system.img"
sparse="$f2/system_sparse.img"

clear

echo "#######################################"
echo "         Android Image Modifier        "
echo "#######################################"
echo

read -p "Enter location of extracted files : " loc
file1=$loc/system.transfer.list
file2=$loc/system.new.dat

if [[ -f "$file1" ]] && [[ -f "$file2" ]]; then
	
	echo
	echo Files found
	echo
	echo "Decompressing DAT (sparse data) -> EXT4 (raw image)"
	echo 

	if [[ -e "$f2" ]]; then
		echo output folder exists
	else
		mkdir $f2
	fi 
	
	./sdat2img/sdat2img.py $file1 $file2 $sys | grep Done!
	
	if [ -e "$f1" ]; then
		echo "Mounting image"
	else
		echo 
		echo "Default path $f1 does not exist"
		read -p "specify path to mount" f1
		if [ -e "$f1" ]; then
			echo "Mounting image"
		else
			exit 1
		fi
	fi
	sudo mount -t ext4 -o loop $sys $f1
	echo
	echo "Image mounted at $f1"
	echo
	echo "Now make required changes to the image."
	echo

	read -p "Press any key to start repacking..." key

	if [ "$key" = '' ]; then
    	sudo umount $f1
    	echo " "
    	echo Image unmounted
    	img2simg $sys $sparse
    	echo Converting to sparse_img complete.
    	echo
    	mkdir $f2/dat
    	./img2sdat/img2sdat.py $sparse -o $f2/dat
    	echo
    	echo "Compressed raw image to sparse data."
    	echo "Process finished."
	else
    	echo "Script terminated."
	fi
else
	echo "Files not found."
fi
