#!/bin/bash

# example dfm.mime
#
# video/* :mplayer
# text/* :urxvt -e emacs -nw
# image/vnd.djvu :~/script/apvlv.sh
# image/* :feh
# audio/mpeg :mplayer
#

D_CONF="-fn -xos4-terminus-medium-r-normal--12-120-72-72-c-60-*-* -nb #cccccc -nf #111111 -sb #111111 -sf #cccccc"
DMENU="dmenu $D_CONF"
C_DIR="$HOME/.config/dfm"
H_FILE="${C_DIR}/dfm.last"
M_FILE="${C_DIR}/dfm.mime"

is_type () {
    if file --mime "$1" | cut -f2 -d: | awk '{print $1}' | grep "$2"
    then
	return 0
    fi
    return 1
}

cd_dir () {
    cd "$1"
    echo "`pwd`" > "$H_FILE"
}

open_file () {
    eval "$1 \"$2\""
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
	if is_type "$1" `echo $line | cut -f1 -d:`
	then
	    open_file `echo $line | cut -f2 -d:` "$1"
	    return 0
	fi
    done < $M_FILE
    return 1
}

make_mime () {
    new_mime=`file --mime "$1" | cut -f2 -d: | awk '{print $1}' | sed -e 's/;//g'`

    if [ "$new_mime" ]; then
	po=`echo "" | $DMENU -p "Enter program for $new_mime: "`
	if [ "$po" ]; then
	    echo "$new_mime :$po" >> $M_FILE
	    return 0
	fi
    fi
    return 1
}

run_ext () {
    ext=`echo "$1" | awk '{print $1}'`
    param=`echo "$1" | sed s/$ext//g`

    if eval '$C_DIR/$ext $param'
    then
	return 0
    else
	`echo "Extension not found" | $DMENU -p "$ext"`
	return 1
    fi
}

if [ -d "$C_DIR" ]; then
    if [ -e "$H_FILE" ]; then
	y_n=`echo -e "Yes\nNo" | $DMENU -p "Open last dir?"`
	if [ Yes = "$y_n" ]; then
	    cd_dir "`cat "$H_FILE"`"
	elif [ "" = "$y_n" ]; then
	    exit 0
	fi
    fi
else
    mkdir -p "$C_DIR"
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
    elif run_program "$var"
    then
	var=`ls`
	continue
    elif [ x"$var" = x"shell:"  ]; then
	run_cmd
    elif [ x"`echo $var | awk '{print $1}'`" = x"ext:" ]; then
	run_ext "`echo "$var" | cut -f2 -d:`"
    elif [ x"`echo $var | awk '{print $1}'`" = x"sh:" ]; then
	eval "`echo "$var" | cut -f2 -d:`"
    elif [ x"$var" = x"" ]; then
	exit 0
    else
	make_mime "$var"
    fi

    var=`ls`
done
