#!/usr/bin/bash

################################################################################
#                                                                              #
#  pkgm.sh - a shell package management                                        #
#  Author:       Martin Haedecke                                               #
#  Version:      1.0                                                           #
#  Dependencies: bash, coreutils, gzip, tar                                    #
#  Usage: pkgm.sh [Mode] [Archive|Package file|Source path] [Target path]      #
#    Mode: init [Source path] - creates package file and archive               #
#    Mode: install [Archive] [Target path] - installs archive                  #
#    Mode: uninstall [Package file] [prefix] - uninstalls package              #
#                                                                              #
################################################################################

MODE_CHK=$(echo " init install uninstall " | grep -oP " $1 ")
if [ $? == 0 ]; then
    MODE=$1
    echo "Mode: $MODE"
else
    echo "Mode unknown"
    exit 1
fi

OPT_IN=$2
if [[ $OPT_IN ]]; then
    echo "Opt-IN: $OPT_IN"
else
    echo "Input option not set."
    exit 1
fi

OPT_OUT=$3
if [[ $OPT_OUT ]]; then
    echo "Opt-OUT: $OPT_OUT"
else
    echo "Output option not set."
    exit 1
fi

function as_root {

    if   [ $EUID = 0 ]; then $*
    elif [ -x /usr/bin/sudo ]; then sudo $*
    else su -c \\"$*\\"
    fi

}

function init {

    PACKAGE_NAME="$(basename $OPT_IN).pkgm"
    echo "Init: package file is $OPT_OUT/$PACKAGE_NAME"
    touch $OPT_OUT/$PACKAGE_NAME
    echo "TOP=$OPT_OUT" > $OPT_OUT/$PACKAGE_NAME

    echo "DATE=$(date)" >> $OPT_OUT/$PACKAGE_NAME
    for PKGM_DIR in $(find $OPT_IN -type d -printf '%P\n'); do
        echo "DIR=$PKGM_DIR" >> $OPT_OUT/$PACKAGE_NAME
    done
    for PKGM_DIR in $(find $OPT_IN -type f -printf '%P\n'); do
        echo "FILE=$PKGM_DIR" >> $OPT_OUT/$PACKAGE_NAME
    done
    echo "Init: directory and file structure written to $OPT_OUT/$PACKAGE_NAME"

    tar czf $OPT_OUT/$PACKAGE_NAME.tar.gz -C $OPT_IN .
    echo "Init: created archive $OPT_OUT/$PACKAGE_NAME.tar.gz"

}

function install {

    PACKAGE_NAME=$(echo $OPT_IN | cut -d. -f1-2)
    TMPDIR=$(grep TOP $PACKAGE_NAME | cut -d= -f2)
    echo "Install: set up $TMPDIR"
    echo "Install: package file is $TMPDIR/$(basename $PACKAGE_NAME)"

    # create top level dir, if not exists
    mkdir -p $OPT_OUT
    echo "Install: create top level directory"

    tar -xzf $OPT_IN -C $OPT_OUT
    echo "Install: extract archive to $OPT_OUT"

}

function uninstall {

    PACKAGE_NAME=$OPT_IN
    echo "Uninstall: package file is $(basename $PACKAGE_NAME)"

    PREFIX=$OPT_OUT
    echo "Uninstall: prefix is $PREFIX"
    cd $PREFIX

    for file in $(grep FILE $PACKAGE_NAME | cut -d= -f2); do
        echo $(pwd)/$file
        if [ -O $file ]; then
            rm -f $(pwd)/$file
        else
            as_root rm -f $(pwd)/$file
        fi
    done
    echo "Uninstall: all files removed"

    #TODO remove directories

}

case "$MODE" in

    "init")
        init
        ;;
    "install")
        install
        ;;
    "uninstall")
        uninstall
        ;;
    *)
        echo "Mode is unknown."
        ;;

esac

exit 0
