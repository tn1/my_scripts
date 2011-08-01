#!/bin/bash

DMENU="dmenu  -fn -xos4-terminus-medium-r-normal--12-120-72-72-c-60-*-* -nb #cccccc -nf #111111 -sb #111111 -sf #cccccc"
COMMAND="slock
hibernate
reboot
halt"

COMMAND=`echo "${COMMAND}" | $DMENU -l 4`

case $COMMAND in
    scrot)
	COMMAND="slock"
	;;
    hibernate)
	COMMAND="sudo hibernate-ram"
	;;
    reboot)
	COMMAND="sudo shutdown -r now"
	;;
    halt)
	COMMAND="sudo shutdown -h now"
	;;
esac

if [ "$COMMAND" != "" ]; then
    if [ "`echo -e \"Yes\nNo\" | $DMENU -p \"Run ${COMMAND}?\"`" = "Yes" ]; then
	eval $COMMAND
    fi
fi
