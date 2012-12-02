#!/bin/bash
# Author: Michael Ambrus (ambrmi09@gmail.com)
# 2011-01-22

if [ -z $INSTALL_AND_SETUP_SH ]; then

INSTALL_AND_SETUP_SH="install_and_setup.sh"

function install_and_setup() {
	if [ $# -ge 1 ]; then
		MAKEOPTS=$@
	fi

	if [ -z "${MAKEOPTS}" ]; then
		MAKEOPTS="-j$(cat /proc/cpuinfo | grep processor | wc -l)"
	fi

	set -e

	source s3.user_response.sh
	source s3.test_install_bin.sh
	source s3.test_install_pkg.sh

	#set -u

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
		--enable-ft2232_libftdi	\
		--prefix=${HOME}
	make $MAKEOPTS
	make install
}

source s3.ebasename.sh

if [ "$INSTALL_AND_SETUP_SH" == $( ebasename $0 ) ]; then
	#Not sourced, do something with this.
	install_and_setup $@
	exit $?
fi

fi
