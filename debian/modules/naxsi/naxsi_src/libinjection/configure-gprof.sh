#!/bin/sh
set -e
#
# gprof build
#
make clean
export CFLAGS="-O3 -pg -ansi"
make -e

