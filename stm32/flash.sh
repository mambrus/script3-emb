#!/bin/bash
FLASH_STM32_SH="flash_stm32.sh"

HOST=localhost
PORT=4444
OTN="telnet $HOST $PORT"
BIN=main.bin

function flashit() {
	openocd_cmd.exp reset halt
	openocd_cmd.exp flash probe 0
	openocd_cmd.exp stm32x mass_erase 0
	openocd_cmd.exp flash write_bank 0 main.bin 0
	openocd_cmd.exp reset halt
}

if [ "$FLASH_STM32_SH" == $( basename $0 ) ]; then
	#Not sourced, do something with this.
	if [ $# -ge 1 ]; then
		openocd_cmd.exp $@
	else
		flashit
	fi
fi

