#!/usr/bin/bash

################################################################################
#                                                                              #
#  pkgm.sh - a shell package management                                        #
#  Author:       Martin Haedecke                                               #
#  Version:      1.0                                                           #
#  Dependencies: bash, coreutils, gzip, tar                                    #
#  Usage: pkgm.sh [Mode] [Archive|Package file|Source path] [Target path]      #
#    Mode: init [Source path] [Target path] - creates package file and archive #
#    Mode: install [Archive] [Target path] - installs archive                  #
#    Mode: uninstall [Package file] [prefix] - uninstalls package              #
#                                                                              #
################################################################################

MODE_CHK=$(echo " init install uninstall " | grep -oP " $1 ")
if [ $? == 0 ]; then
    MODE=$1
    echo "Mode: $MODE"
else
    echo "Mode unknown, please use one of init|install|uninstall."
    exit 1
fi

OPT_IN=$2
if [[ $OPT_IN ]]; then
    echo "Input: $OPT_IN"
else
    echo "Input option not set."
    exit 1
fi

OPT_OUT=$3
if [[ $OPT_OUT ]]; then
    echo "Output: $OPT_OUT"
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
    touch $OPT_OUT/$PACKAGE_NAME
    if [ $? == 0 ]; then
        echo "Init: package file created $OPT_OUT/$PACKAGE_NAME"
    else
        echo "Init: Could not create package file, exiting!"
        exit 1
    fi
    echo "TOP=$OPT_OUT" > $OPT_OUT/$PACKAGE_NAME
    echo "DATE=$(date +%s)($(date +%Y%m%d_%H:%M:%S))" >> $OPT_OUT/$PACKAGE_NAME

    # write directory structure
    for PKGM_DIR in $(find $OPT_IN -type d -printf '%P\n'); do
        echo "DIR=$PKGM_DIR" >> $OPT_OUT/$PACKAGE_NAME
    done
    # write file list
    for PKGM_DIR in $(find $OPT_IN -type f -printf '%P\n'); do
        echo "FILE=$PKGM_DIR" >> $OPT_OUT/$PACKAGE_NAME
    done
    echo "Init: directory and file structure written to $OPT_OUT/$PACKAGE_NAME"

    # create archive
    tar czf $OPT_OUT/$PACKAGE_NAME.tar.gz -C $OPT_IN .
    echo "Init: created archive $OPT_OUT/$PACKAGE_NAME.tar.gz"

}

function install {

    # create top level dir, if not exists
    if [ -d "$OPT_OUT" ]; then
        echo "Install: target directory exists"
    else
        echo "Install: target directory does not exist, please create it!"
        exit 1
    fi

    # extract files to target directory
    OWNER="$(stat -c '%U' "$OPT_OUT")"
    if [ "${OWNER}" != "${USER}" ]; then
        as_root tar -xzf $OPT_IN -C $OPT_OUT
        echo "Install: root mode!"
    else
        tar -xzf $OPT_IN -C $OPT_OUT
        echo "Install: user mode"
    fi
    echo "Install: extracted archive to $OPT_OUT"

}

function uninstall {

    PACKAGE_NAME=$OPT_IN
    echo "Uninstall: package file is $(basename $PACKAGE_NAME)"

    PREFIX=$OPT_OUT
    echo "Uninstall: prefix is $PREFIX"
    cd $PREFIX

    OWNER="$(stat -c '%U' "$OPT_OUT")"
    if [ "${OWNER}" != "${USER}" ]; then
        echo "Uninstall: root mode!"
    else
        echo "Uninstall: user mode."
    fi
    for file in $(grep FILE $PACKAGE_NAME | cut -d= -f2); do
        echo "Uninstall: $(pwd)/$file"
        if [ "${OWNER}" != "${USER}" ]; then
            as_root rm -f $(pwd)/$file
        else
            rm -f $(pwd)/$file
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
