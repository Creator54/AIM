#!/bin/bash

f1=tmp
f2=system
sys=$f1/system.img
sparse=$f1/system_sparse.img

clear

echo "#######################################"
echo "         Android Image Modifier        "
echo "#######################################"
echo
zip_file="$(ls -a | grep .zip)"
if [[ -e "$zip_file" ]]; then
	mkdir $f1 $f2
	unzip $zip_file -d $f1
	loc=$f1
	if [[ -e "$loc/system.new.dat.br" ]]; then
		brotli -f -d $loc/*.br
	fi
	file1=$loc/system.transfer.list
	file2=$loc/system.new.dat

	if [[ -f "$file1" ]] && [[ -f "$file2" ]]; then
	
		echo
		echo "Decompressing DAT (sparse data) -> EXT4 (raw image)"
		echo 
	
		./sdat2img/sdat2img.py $file1 $file2 $sys | grep Done!
	
		sudo mount -t ext4 -o loop $sys $f2
		echo
		echo "Image mounted at $f2"
		echo
		echo "Now make required changes to the image."
		echo
		
		read -p "Press Enter to start repacking..." key
		if [ "$key" = '' ]; then
    		sudo umount $f2
    		echo " "
    		echo Image unmounted
    		img2simg $sys $sparse
    		echo
    		echo Converting to sparse_img complete.
   		 	echo
	    	if [[ -e "$loc/system.new.dat.br" ]]; then
    			./img2sdat/img2sdat.py $sparse -o $f1 -v 4
    			echo
    			echo "System supports brotli compression ."
    			echo
    			echo " 1 - fastest/least compression"
    			echo " 6 - default aosp compression"
    			echo "11 - slowest/max compression"
    			echo
    			read -p "Enter compression level(1-11): " l
				brotli -f -$l $f1/system.new.dat
				echo
			else
				./img2sdat/img2sdat.py $sparse -o $f1
			fi
    	fi
	fi
	echo Zipping up
	echo
	if [[ -e "$loc/system.new.dat.br" ]]; then
		rm $f1/system.new.dat
	fi
	rm $sys $sparse && cd $f1 && zip test_ROM.zip -r *
	mv test_ROM.zip ../ && cd ../ && rm -rf $f1 $f2
	echo
	echo "All Done. Time for testing :)"
	echo
else
	echo "Copy ROM zip to this folder."
fi