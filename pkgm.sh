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
#    Mode: uninstall [Package file] - uninstalls package                       #
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

if [ "$MODE" == "install" ]; then
    OPT_OUT=$3
    if [[ $OPT_OUT ]]; then
        echo "Opt-OUT: $OPT_OUT"
    else
        echo "Output option not set."
        exit 1
    fi
fi

function init {

    PACKAGE_NAME="$(basename $OPT_IN).pkgm"
    echo "File: $PACKAGE_NAME"

    rm -f ./$PACKAGE_NAME ./$PACKAGE_NAME.tar.gz
    echo "Init: cleaned up $PACKAGE_NAME"

    touch ./$PACKAGE_NAME
    echo "DATE=$(date)" > $PACKAGE_NAME
    for PKGM_DIR in $(find $OPT_IN -type d); do
        echo "DIR=$PKGM_DIR" >> $PACKAGE_NAME
    done
    for PKGM_DIR in $(find $OPT_IN -type f); do
        echo "FILE=$PKGM_DIR" >> $PACKAGE_NAME
    done
    echo "Init: directory and file structure written to ./$PACKAGE_NAME"

    tar czf $PACKAGE_NAME.tar.gz ./$(basename $OPT_IN)
    echo "Init: created archive ./$PACKAGE_NAME.tar.gz"

}

function install {

    PACKAGE_NAME=$(echo $OPT_IN | cut -d. -f1-2)
    echo "File: $PACKAGE_NAME"
    echo "TARGET=$OPT_OUT" >> $PACKAGE_NAME

    # create top level dir, if not exists
    mkdir -p $OPT_OUT
    echo "Install: create top level directory"

    tar -xzf $OPT_IN -C $OPT_OUT
    echo "Install: extract archive to $OPT_OUT"

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
