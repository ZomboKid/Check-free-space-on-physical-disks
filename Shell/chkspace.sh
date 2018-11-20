#!/bin/bash

trigger=$1 #set min free space in MB
if [ "$trigger" == "" ]; then
    echo "ERROR. You must set min free space in MB in command line argument for this script."
    exit 1
fi

IFS=$'\n'
#----------------------------------------------------------------------
array=($(df -Th -BM |  awk  '{print $1,$2,$5,$7}'))

for j in ${!array[@]}; do
#exclude all filesystem types not in list: ext.*|xfs|tmp.*
    fs_type=($(echo ${array[j]} | awk '{print $2}'))
    if ! [[ $fs_type =~ ^(ext.*|xfs|tmp.*)$ ]]; then
        unset array[j]
    fi
#exclude /boot|/swap partition
    fs_partition=($(echo ${array[j]} | awk '{print $4}'))
    if [[ $fs_partition =~ ^(/boot|/swap)$ ]]; then
        unset array[j]
    fi
done

for j in ${!array[@]}; do
#leave only filesystem types ext.*|xfs and /tmp partition
    fs_type=($(echo ${array[j]} | awk '{print $2}'))
    fs_partition=($(echo ${array[j]} | awk '{print $4}'))
    if ! [[ $fs_type =~ ^(ext.*|xfs)$ ]]; then
        if ! [[ $fs_partition =~ ^(/tmp)$ ]]; then
            unset array[j]
        fi
    fi
done

for j in ${!array[@]}; do
    free_space=($(echo ${array[j]} | awk '{print $3}' | sed 's/.$//'))
    if [[ $free_space -lt $trigger ]]; then
        echo "ERROR. On device "$(echo ${array[j]} | awk '{print $1}')" that is mounted to "$(echo ${array[j]} | awk '{print $4}')" is "$free_space"MB free. It is less than "$trigger"MB."
        exit 1
    fi
done
#----------------------------------------------------------------------
unset IFS
