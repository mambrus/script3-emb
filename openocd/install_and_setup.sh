#!/bin/bash
# Author: Michael Ambrus (ambrmi09@gmail.com)
# 2011-01-22

if [ $# -ge 1 ]; then
	MAKEOPTS=$@
fi

if [ -z "${MAKEOPTS}" ]; then
	MAKEOPTS="-j3"
fi

source user_response.sh
source test_install.sh

test_install_bin gcc
test_install_bin make
test_install_bin automake
test_install_bin autoconf
test_install_bin autoheader
test_install_bin aclocal
test_install_bin libtool
test_install_bin git

test_install_pkg libftdi-dev

FTDI_RULE='
BUS!="usb", ACTION!="add", SUBSYSTEM!=="usb_device", GOTO="kcontrol_rules_end"

SYSFS{idProduct}=="0003", SYSFS{idVendor}=="15ba", MODE="664", GROUP="plugdev"

LABEL="kcontrol_rules_end"
'

if [ -z "$(grep -R 15ba /etc/udev/rules.d/*)" ]; then
	set +e
	ask_user_continue \
		"No udev rule set up for ftdi-chip. Set up template? (Y/n)"\
		"Setting up ruleset for ftdi-chip..."\
		"Skipping..."
	RC=$?
	set -e
	if [ $RC -eq 0 ]; then
		#sudo create_udev_file "45-ft2232.rules" "$FTDI_RULE"
		echo "$FTDI_RULE" | \
			sudo tee /etc/udev/rules.d/45-ft2232.rules 1>/dev/null
	fi
fi

set -u
set -e

mkdir OpenOCD
cd OpenOCD
git clone git://openocd.git.sourceforge.net/gitroot/openocd/openocd src
mkdir build
cd src
git reset --hard v0.4.0-rc2
./bootstrap
cd ../build/
../src/configure \
  --enable-maintainer-mode \
  --enable-ft2232_libftdi  \
  --prefix=${HOME}
make $MAKEOPTS
make install
