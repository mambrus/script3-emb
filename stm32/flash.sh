#!/bin/bash

if [ -z $FLASH_SH ]; then

FLASH_SH="flash.sh"

BIN=main.bin

function flash() {
	emb.openocd.cmd.exp reset halt
	emb.openocd.cmd.exp flash probe 0
	emb.openocd.cmd.exp stm32x mass_erase 0
	emb.openocd.cmd.exp flash write_bank 0 $1 0
	emb.openocd.cmd.exp reset halt
}

source s3.ebasename.sh

if [ "$FLASH_SH" == $( ebasename $0 ) ]; then
	#Not sourced, do something with this
	set -e
	set -u

	if [ $# -ge 1 ]; then
		emb.openocd.cmd.exp $@
	else
		flash $BIN
	fi
fi

fi
