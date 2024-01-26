# pkgm
a shell package manager

the basic idea is a simple shell script to install and uninstall packages build by source.
configure the package with a prefix or make a DESTDIR installation.
finally you can manage the installed directories and files with pkgm.

there are some dependencies:
* bash
* coreutils
* gzip
* tar
             
usage:
pkgm.sh [init|install|uninstall] [archive|package file|source path] [prefix|target path]

examples:
* creates package file and archive: pkgm.sh init [source path]
* installs archive: pkgm.sh install [archive] [target path]
* uninstalls package: pkgm.sh uninstall [package file] [prefix]
