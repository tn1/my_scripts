#!/bin/bash

D_CONF="-fn -xos4-terminus-medium-r-normal--12-120-72-72-c-60-*-* -nb #cccccc -nf #111111 -sb #111111 -sf #cccccc"
DMENU="dmenu $D_CONF"
C_DIR="$HOME/.config/dfm/"
H_FILE="${C_DIR}dfm.last"
M_FILE="${C_DIR}dfm.mime"

is_type () {
    if file --mime "$1" | grep "$2" &> /dev/null
    then
	return 0
    fi
    return 1
}

cd_dir () {
    cd "$1"
    echo "`pwd`" > $H_FILE
}

open_file () {
    eval "${1} \"${2}\"" &> /dev/null
}

run_cmd () {
    cmd="echo Hello, ${USER}!"
    while [ "$cmd" ] ; do
	res=`eval "$cmd"`
	cmd=`echo "$res" | $DMENU -p sh`
    done
    return 0
}

if [ -d "$C_DIR" ]; then
    if [ ! -e "$M_FILE" ]; then
	echo Exit | `$DMENU -p "Create $M_FILE. Format: mime program"`
	exit 1
    fi

    if [ -e "$H_FILE" ]; then
	y_n=`echo -e "Yes\nNo" | $DMENU -p "Open last dir?"`
	if [ "$y_n" = "Yes" ]; then
	    cd_dir "`cat "$H_FILE"`"
	elif [ "$y_n" = "" ]; then
	    exit 0
	fi
    fi
elif [ ! -d "$C_DIR" ]; then
    mkdir $C_DIR
    echo Exit | `$DMENU -p "Create $M_FILE. Format: mime program"`
    exit 1
else
    return 0
fi

var=`ls`
M_FILE=`cat $M_FILE`

while true; do
    if [ "$var" ]; then
	var=`echo -e "../\n$var" | $DMENU -p "dfm"`
    else
	var=`echo "../" | $DMENU -p "dfm"`
    fi

    if [ -d "$var" ]; then
	cd_dir "$var"
    elif [ "$var" = "shell:" ]; then
	run_cmd
    elif [ "`echo $var | awk '{print $1}'`" = "sh:" ]; then
	eval "`echo \"$var\" | cut -f2 -d:`"
    elif [ "$var" = "" ]; then
	exit 0
    else
        echo "$M_FILE" | while read line
	do
	    if is_type "$var" `echo $line | cut -f1 -d:'`
	    then
		open_file "`echo $line | cut -f2 -d:`" "$var";
		break
	    fi
	done

    fi

    var=`ls`
done
