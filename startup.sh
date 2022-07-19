#!/bin/bash

if [ ! -z "$PUID" ] && [ ! -z "$PGID" ]; then
    groupmod -o -g "$PGID" moo
    usermod -o -u "$PUID" moo
    chown -R moo:moo /home/*
	gosu moo restart "$1"
else
	restart "$1"
fi