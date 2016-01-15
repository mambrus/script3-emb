#!/bin/bash

if [ -z $FLASH_SH ]; then

FLASH_SH="flash.sh"

# Preferred flash method (bin). Because its faster and doesnt erase more than it
# needs to)
function flash_bin() {
	echo "Flashing binary"
	emb.openocd.cmd.exp reset halt						&& \
	emb.openocd.cmd.exp flash probe 0					&& \
	emb.openocd.cmd.exp stm32f1x mass_erase 0			&& \
	emb.openocd.cmd.exp flash write_bank 0 $1 0			&& \
	emb.openocd.cmd.exp reset halt						&& \
	echo "Flashed [$1] OK"
}

# Generic formatted flash. Lets OpenOCD figure out the format
function flash_form() {
	echo "Flashing formatted"
	emb.openocd.cmd.exp reset halt						&& \
	emb.openocd.cmd.exp flash probe 0					&& \
	emb.openocd.cmd.exp stm32f1x mass_erase 0			&& \
	emb.openocd.cmd.exp flash write_image 1 1 $1 		&& \
	emb.openocd.cmd.exp reset halt						&& \
	echo "Flashed [$1] OK"
}

source s3.ebasename.sh

if [ "$FLASH_SH" == $( ebasename $0 ) ]; then
	#Not sourced, do something with this
	set -e
	#set -u
	source s3.user_response.sh

	#Several valid formats may be present. Next line chooses in preferred order

	if [ $# -eq 1 ]; then
		IMG=${1}
	elif [ $# -eq 0 ]; then
		#**Note** that the first one found is selected
		IMG=$( (ls *.bin 2>/dev/null; ls *.elf 2>/dev/null) | head -n1)
	else
		echo "Err0r: Only one or zero arguments allowed" 1>&2
		echo "(Zero for loading first *.bin found)" 1>&2
		exit 1
	fi

	EXT=$(echo $IMG | sed -e 's/\(.*\)\.//')

	if [ $# -eq 0 ] && [ "X${IMG}" != "X" ] ; then
		ask_user_continue "Flash target with [${IMG}]? (Y/n)" || exit 1
	fi

	if [ "X${IMG}" == "X" ] ; then
		echo "Err0r: No flash-able file found or provided" 1>&2
		exit 1
	fi

	if [ "X${EXT}" == "Xbin" ]; then
		flash_bin $IMG
		exit $?
	else
		flash_form $IMG
		exit $?
	fi
fi

fi
