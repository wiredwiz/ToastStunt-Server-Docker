#!/bin/bash

# Copyright (c) 2022, Thaddeus Ryker.
# Contains many contributions by Lisdude (massive thanks to him) to be more functional and handle quotes properly
# This script handles building the command line parameters for the moo binary execution based on the defined environmental variables.

declare -a CONFIG_PARAMS=()
declare -a PORT_PARAMS=()

if [ "$EMERGENCY_MODE" = "true" ]; then
    CONFIG_PARAMS+=("-e")
fi
if [ ! -z "$START_SCRIPT" ]; then
    CONFIG_PARAMS+=("-f")
    CONFIG_PARAMS+=("$START_SCRIPT")
fi
if [ ! -z "$START_LINE" ]; then
    CONFIG_PARAMS+=("-c")
    CONFIG_PARAMS+=("$START_LINE")
fi
if [ "$CLEAR_MOVE" = "true" ]; then
    CONFIG_PARAMS+=("-m")
fi
if [ ! -z "$WAIF_TYPE" ]; then
    CONFIG_PARAMS+=("-w")
    CONFIG_PARAMS+=("$WAIF_TYPE")
fi
if [ "$NO_OUTBOUND" = "true" ]; then
    CONFIG_PARAMS+=("-O")
fi
if [ ! -z "$IPV4" ]; then
    CONFIG_PARAMS+=("-4")
    CONFIG_PARAMS+=("$IPV4")
fi
if [ ! -z "$IPV6" ]; then
    CONFIG_PARAMS+=("-6")
    CONFIG_PARAMS+=("$IPV6")
fi
if [ ! -z "$TLS_CERT" ]; then
    CONFIG_PARAMS+=("-r")
    CONFIG_PARAMS+=("$TLS_CERT")
fi
if [ ! -z "$TLS_KEY" ]; then
    CONFIG_PARAMS+=("-k")
    CONFIG_PARAMS+=("$TLS_KEY")
fi
if [ ! -z "$FILE_DIR" ]; then
    CONFIG_PARAMS+=("-i")
    CONFIG_PARAMS+=("$FILE_DIR")
else
	FILE_DIR="files"
fi
if [ ! -z "$EXEC_DIR" ]; then
    CONFIG_PARAMS+=("-x")
    CONFIG_PARAMS+=("$EXEC_DIR")
else
	EXEC_DIR="executables"
fi
if [ ! -z "$PORT" ]; then
    PORT_PARAMS+=("-p")
    PORT_PARAMS+=("${PORT}")
fi
if [ ! -z "$TLS_PORT" ]; then
    PORT_PARAMS+=("-t")
    PORT_PARAMS+=("$TLS_PORT")
fi

export EXEC_DIR
export FILE_DIR
export PORT_PARAMS
export CONFIG_PARAMS