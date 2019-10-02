#!/bin/bash

set -ue

declare -A paths
export paths

if [ $# -lt 1 ]; then
    while read line; do 
        echo "$line t=$(date +%s%N)";
    done < /dev/stdin
    exit
fi

while read -r file time; do
    time="$(echo "$time" | awk -F= '{print $2}')";
    ctime="$(($time - ${lasttime-$time}))";
    lasttime="$time";
    file="$(realpath -m --relative-to=. "$file")"

    while [ "x$file" != "x." ]; do
        paths[$file]=$(($ctime+${paths[$file]-0}))
        file="$(dirname "$file")"
    done
done <<<$(grep "$1" -oe ' [^ ]* t=.*$' | grep -e '/')

function getpath() {
    if [ "x$1" == "x." ]; then
        for i in "${!paths[@]}"; do
            echo "${paths[$i]} $i";
        done | grep -e "^[^ ]* [^/]*$" | sort -rn
    else
        out="$(
        for i in "${!paths[@]}"; do
            echo "${paths[$i]} $i";
        done | grep -e "^[^ ]* $1/[^/]*$" | sort -rn)"
        if [ "x$out" == "x" ]; then
            for i in "${!paths[@]}"; do
                echo "${paths[$i]} $i";
            done | grep -e "^[^ ]* $1$" | sort -rn
        else
            echo "$out"
        fi
    fi
}

function convertsecs() {
    h=$(bc <<< "${1}/3600")
    m=$(bc <<< "(${1}%3600)/60")
    s=$(bc <<< "${1}%60")
    printf "%02d:%02d:%05.2f\n" $h $m $s
}

function popdialog() {
    selected="$1"

    while [ "x$selected" != "x" ]; do
        if [ "x$selected" != "x." ]; then
            extra=".. ($(basename "$(dirname "$selected" | sed -e 's_^\.$_/_' -e 's/ //g')"))"
        fi
        newselected="$(dialog --stdout --menu "Kernel NCDU" 0 0 0 ${extra-} $(
        while read -r ctime file; do
            echo "$(basename "${file}")" "$(convertsecs "$(bc <<< "scale=10; ${ctime}/1000000000")")"
        done <<<"$(getpath "$selected")"))"
        if [ "x$selected" != "x." ] && [ "x$newselected" != "x.." ] && [ "x$newselected" != "x$(basename "$selected")" ]; then
            selected="$selected/$newselected"
        elif [ "x$newselected" == "x.." ] || [ "x$newselected" == "x$(basename "$selected")" ]; then
            unset extra
            selected="$(dirname "$selected")"
        else
            selected="$newselected"
        fi
    done
}

#getpath arch/x86/kvm

popdialog .
