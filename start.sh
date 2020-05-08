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

echo "Enter system.transfer.list location"
read file1
file1+=/system.transfer.list
echo "Enter system.new.dat location"
read file2
file2+=/system.new.dat

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
		echo "specify path to mount"
		read f1
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

	read -n1 -r -p "Press any key to start repacking..." key

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
    	echo "Wrong key."
	fi
else
	echo "Files not found."
	echo "Copy system.transfer.list & system.new.dat to input."
fi
