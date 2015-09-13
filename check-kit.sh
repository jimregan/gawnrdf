#!/bin/sh

prog=$(which wget)
if [ x"$prog" = x ]
then
	echo "wget is needed by prep-data.sh"
	exit 1
fi

prog=$(which perl)
if [ x"$prog" = x ]
then
	echo "perl is needed by... all the Perl scripts"
	echo "srsly, how do you not have perl?"
	exit 1
fi

prog=$(which rapper)
if [ x"$prog" = x ]
then
	echo "rapper is needed by extract-mcr.sh"
	echo "On Debian-like systems: apt-get install raptor2-utils"
	exit 1
fi
