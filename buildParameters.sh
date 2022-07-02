#!/bin/sh

CONFIG_PARAMS="";
PORT_PARAMS="";
if [ ! -z "$START_SCRIPT" ] ; then
	CONFIG_PARAMS="$CONFIG_PARAMS -f \"$START_SCRIPT\" "
fi
if [ ! -z "$START_LINE" ] ; then
	CONFIG_PARAMS="$CONFIG_PARAMS -c \"$START_LINE\" "
fi
if [ "$CLEAR_MOVE" = "true" ] ; then
	CONFIG_PARAMS="$CONFIG_PARAMS -m "
fi
if [ ! -z "$WAIF_TYPE" ] ; then
	CONFIG_PARAMS="$CONFIG_PARAMS -w $WAIF_TYPE "
fi
if [ "$NO_OUTBOUND" = "true" ] ; then
	CONFIG_PARAMS="$CONFIG_PARAMS -O "
fi
if [ ! -z "$IPV4" ] ; then
	CONFIG_PARAMS="$CONFIG_PARAMS -4 \"$IPV4\" "
fi
if [ ! -z "$IPV6" ] ; then
	CONFIG_PARAMS="$CONFIG_PARAMS -6 \"$IPV6\" "
fi
if [ ! -z "$TLS_CERT" ] ; then
	CONFIG_PARAMS="$CONFIG_PARAMS -r \"$TLS_CERT\" "
fi
if [ ! -z "$TLS_KEY" ] ; then
	CONFIG_PARAMS="$CONFIG_PARAMS -k \"$TLS_KEY\" "
fi
if [ ! -z "$FILE_DIR" ] ; then
	CONFIG_PARAMS="$CONFIG_PARAMS -i \"$FILE_DIR\" "
else
	FILE_DIR="files"
fi
if [ ! -z "$EXEC_DIR" ] ; then
	CONFIG_PARAMS="$CONFIG_PARAMS -x \"$EXEC_DIR\" "
else
	EXEC_DIR="executables"
fi
if [ ! -z "$PORT" ] ; then
	PORT_PARAMS="$PORT_PARAMS -p $PORT"
fi
if [ ! -z "$TLS_PORT" ] ; then
	PORT_PARAMS="$PORT_PARAMS -t $TLS_PORT "
fi

export EXEC_DIR
export FILE_DIR
export PORT_PARAMS
export CONFIG_PARAMS