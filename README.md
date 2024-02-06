# pkgm
a shell package manager

pkgm is a simple shell script to install and uninstall packages build by source.
make a DESTDIR installation or set the configuration prefix twice.
finally you can manage the installed directories and files with pkgm.

## prefix configuration
the prefix is set at configuration and is intended to be the location where the package will be installed after everything is build.
if there are hardcoded paths in the package they would be based on the prefix path.
it's only recommend to use that option if you will build the package twice and the second build use the final location.
with a second final build you will fix hardcoded paths and get a full file list of the first build.

```
./configure --prefix=[path]
```

## DESTDIR installation
DESTDIR allows you to install the package somewhere other than the prefix.
DESTDIR is prepended to all prefix values so that the install location has exactly the same directory structure/layout as the final location.
that option is recommend and offers also a full file list.

```
make install DESTDIR=[path]
```

## dependencies:
* Bourne Again SHell - [bash](https://www.gnu.org/software/bash)
* GNU Core Utilities - [coreutils](https://www.gnu.org/software/coreutils)
* GNU Gzip - [gzip](https://www.gnu.org/software/gzip)
* GNU Tar - [tar](https://www.gnu.org/software/tar)

## usage
pkgm.sh [init|install|uninstall] [archive|package file|source path] [prefix|target path]

examples:
* creates package file and archive: pkgm.sh init [source path]
* installs archive: pkgm.sh install [archive] [target path]
* uninstalls package: pkgm.sh uninstall [package file] [prefix]
