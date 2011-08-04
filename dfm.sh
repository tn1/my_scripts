#!/bin/bash

D_CONF="-fn -xos4-terminus-medium-r-normal--12-120-72-72-c-60-*-* -nb #cccccc -nf #111111 -sb #111111 -sf #cccccc"
DMENU="dmenu $D_CONF"
C_DIR="$HOME/.config/dfm/"
H_FILE="${C_DIR}dfm.last"
M_FILE="${C_DIR}dfm.mime"

is_type () {
    if file --mime "$1" | cut -f2 -d: | awk '{print $1}' | grep $2 &> /dev/null
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

run_program () {
    while read line
    do
	if is_type "$2" `echo $line | cut -f1 -d:`
	then
	    open_file "`echo $line | cut -f2 -d:`" "$2"
	    return 0
	fi
    done < $M_FILE
    return 1
}

make_mime () {
    new_mime=`file --mime "$1" | cut -f2 -d: | awk '{print $1}' | sed -e 's/;//g'`

    if [ "$new_mime" ]; then
	po=`echo "" | $DMENU -p "Enter program for $new_mime: "`
	echo "$new_mime :$po" >> $M_FILE
	return 0
    fi
    return 1
}

if [ -d "$C_DIR" ]; then
    if [ ! -e "$M_FILE" ]; then
	y_n=`echo -e "Yes\nNo" | $DMENU -p "Create $M_FILE. Format: mime program. Exit?"`
	if [ Yes = "$y_n" ];then
	    exit 0
	fi
	y_n=""
    fi

    if [ -e "$H_FILE" ]; then
	y_n=`echo -e "Yes\nNo" | $DMENU -p "Open last dir?"`
	if [ Yes = "$y_n" ]; then
	    cd_dir "`cat "$H_FILE"`"
	elif [ "" = "$y_n" ]; then
	    exit 0
	fi
	y_n=""
    fi
elif [ ! -d "$C_DIR" ]; then
    mkdir -p "$C_DIR"
    y_n=`echo -e "Yes\nNo" | $DMENU -p "Create $M_FILE. Format: mime program. Exit?"`
    if [ Yes = "$y_n" ];then
	exit 0
    fi
    y_n=""
else
    return 0
fi

var=`ls`

while true; do
    if [ "$var" ]; then
	var=`echo -e "../\n$var" | $DMENU -p "dfm"`
    else
	var=`echo "../" | $DMENU -p "dfm"`
    fi

    if [ -d "$var" ]; then
	cd_dir "$var"
    elif run_program "$M_FILE" "$var"
    then
	return 0
    elif [ shell: = "$var"  ]; then
	run_cmd
    elif [ "`echo $var | awk '{print $1}'`" = "sh:" ]; then
	eval "`echo \"$var\" | cut -f2 -d:`"
    elif [ x"$var" = x"" ]; then
	exit 0
    else
	make_mime "$var" || exit 1
    fi

    var=`ls`
done
