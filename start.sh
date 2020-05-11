#!/bin/bash

dir=system
sys=tmp/system.img
sparse=tmp/system_sparse.img

clear

echo "#########################################"
echo "										   "
echo "        Android Image Modifier           "
echo " 		       By Creator54			       "
echo "										   "
echo "#########################################"
echo
zip_file="$(ls -a | grep .zip)"
if [[ -e "$zip_file" ]]; then
	echo ROM found
	mkdir tmp $dir
	unzip $zip_file -d tmp | grep Archive
	echo zip extracted.
	if [[ -e "tmp/system.new.dat.br" ]]; then
		brotli -f -d tmp/*.br
	fi
	file1=tmp/system.transfer.list
	file2=tmp/system.new.dat

	if [[ -f "$file1" ]] && [[ -f "$file2" ]]; then

		echo
		echo "Decompressing DAT (sparse data) -> EXT4 (raw image)"
		echo

		./sdat2img/sdat2img.py $file1 $file2 $sys | grep Done!

		sudo mount -t ext4 -o loop $sys $dir
		echo
		echo "Now u can start editing $dir directory."
		echo 
		read -p "Press enter to start repacking..." key
		if [ "$key" = '' ]; then
    		sudo umount $dir
    		echo " "
    		echo Image unmounted
    		img2simg $sys $sparse
    		echo
    		echo Converting to sparse_img ...
	    	if [[ -e "tmp/system.new.dat.br" ]]; then
    			./img2sdat/img2sdat.py $sparse -o tmp -v 4 | grep Done
    			echo
    			echo "System supports brotli compression."
    			echo
    			echo " 1 - fastest/least compression"
    			echo " 6 - default aosp compression"
    			echo "11 - slowest/max compression"
    			echo
    			read -p "Enter compression level(1-11): " l
				brotli -f -$l tmp/system.new.dat
				echo Brotli compression complete.
			else
				./img2sdat/img2sdat.py $sparse -o tmp | grep
			fi
    	fi
	fi
	echo
	echo Finalizing New_$zip_file ...
	echo
	if [[ -e "tmp/system.new.dat.br" ]]; then
		rm tmp/system.new.dat
	fi
	rm $sys $sparse && cd tmp 
	zip New_$zip_file -r *
	mv New_$zip_file ../ && cd ../ && rm -rf tmp $dir
	echo
	echo "All Done. Time for testing :)"
	echo
else
	echo "Copy ROM zip to this dir."
fi
