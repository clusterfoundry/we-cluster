#!/bin/bash

function msg() {
	echo "$*" | logger -t local0.info -s
}

function check_bin() {
	for bin in $*; do
		echo -n "checking for $bin..."
		path=`which "$bin"`
		if [ $? -ne 0 ]; then
			echo NONE
			return 0
		fi
		echo $path
}
