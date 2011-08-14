#!/bin/bash

DMENU="dmenu  -fn -xos4-terminus-medium-r-normal--12-120-72-72-c-60-*-* -nb #cccccc -nf #111111 -sb #111111 -sf #cccccc"
COMMAND="slock\nhibernate\nreboot\nhalt"

COMMAND=`echo -e "${COMMAND}" | $DMENU -l 4`

case $COMMAND in
    scrot)      COMMAND="slock" ;;
    hibernate)  COMMAND="sudo hibernate-ram" ;;
    reboot)     COMMAND="sudo shutdown -r now" ;;
    halt)       COMMAND="sudo shutdown -h now" ;;
esac

if [ "$COMMAND" != "" ]; then
    if [ "`echo -e \"No\nYes\" | $DMENU -p \"Run ${COMMAND}?\"`" = "Yes" ]; then
	eval $COMMAND
    fi
fi
