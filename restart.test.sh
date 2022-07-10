#!/bin/bash

# Copyright (c) 1992, 1995, 1996 Xerox Corporation.  All rights reserved.
# Portions of this code were written by Stephen White, aka ghond.
# Use and copying of this software and preparation of derivative works based
# upon this software are permitted.  Any distribution of this software or
# derivative works must comply with all applicable United States export
# control laws.  This software is made available AS IS, and Xerox Corporation
# makes no warranty about the software, its performance or its conformity to
# any specification.  Any person obtaining a copy of this software is requested
# to send their name and post office or electronic mail address to:
#   Pavel Curtis
#   Xerox PARC
#   3333 Coyote Hill Rd.
#   Palo Alto, CA 94304
#   Pavel@Xerox.Com

if [ $# -lt 1 -o $# -gt 1 ]; then
	echo 'Usage: restart dbase-prefix'
	exit 1
fi

# If we have no database, copy a fresh one from our moo-init directory
if [ ! -r $1.db ]; then
    if  [ -r ../moo-init/$1.db ]; then
		cp ../moo-init/$1.db $1.db
		echo "Database $1.db not found"
		echo "Copying a fresh toast core database: $1.db"
    else
		echo "Unknown database: $1.db"
		exit 1
	fi
fi

if [ ! "$(ls -A /home/moorepo/src)" ]; then
	cp -R /home/repobackup/src/* /home/moorepo/src
fi

# Build our command line parameters
. buildParameters

mkdir -p $FILE_DIR
mkdir -p $EXEC_DIR

if [ -r $1.db.new ]; then
	mv $1.db $1.db.old
	mv $1.db.new $1.db
	rm -f $1.db.old.gz
	gzip $1.db.old &
fi

if [ -f $1.log ]; then
	cat $1.log >> $1.log.old
	rm $1.log
fi

# Rebuild if specified
if [ "$REBUILD_SERVER" = "true" ]; then
	rm -rf /home/moorepo/build/*
	cd /home/moorepo/build
	cmake ../
	make -j2
	echo Server finished building
	cp moo /usr/local/bin/moo
	echo moo binary copied to moo directory
	cd /home/moo
fi

echo executing: moo "${CONFIG_PARAMS[@]}" "${1}.db" "${1}.db.new" "${PORT_PARAMS[@]}" "2>&1 | tee -i -a" "${1}.log"
echo `date`: RESTARTED >> $1.log
moo "${CONFIG_PARAMS[@]}" "${1}.db" "${1}.db.new" "${PORT_PARAMS[@]}" 2>&1 | tee -i -a "${1}.log"

###############################################################################
# $Log: restart,v $
#
# Revision 3.0.0.0  2022/07/02 00:51:48 Modified for ToastStunt Docker Thad
# ToastStunt 2.7.0
#
# Revision 1.1.1.1  1997/03/03 03:45:05  nop
# LambdaMOO 1.8.0p5
#
# Revision 2.1  1996/02/08  07:25:52  pavel
# Updated copyright notice for 1996.  Release 1.8.0beta1.
#
# Revision 2.0  1995/11/30  05:14:17  pavel
# New baseline version, corresponding to release 1.8.0alpha1.
#
# Revision 1.4  1992/10/23  23:15:21  pavel
# Added copyright notice.
#
# Revision 1.3  1992/08/18  00:34:52  pavel
# Added automatic compression of the .old database and the provision of a new
# log file for each activation, saving the old log file on the end of a
# .log.old file.
#
# Revision 1.2  1992/07/20  23:29:34  pavel
# Trying out an RCS change log in this file to see if it'll work properly.
#
###############################################################################
