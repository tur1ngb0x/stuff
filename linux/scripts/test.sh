#!/usr/bin/env bash

id=$(lsb_release --short --id)
codename=$(lsb_release --short --codename)

if [[ ("$id" != 'Ubuntu') && ("$codename" != 'focal') ]]; then
    echo "This distribution is $id $codename"
    echo 'Incompatible with this script, exiting...'
fi

