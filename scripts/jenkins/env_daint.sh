#!/bin/bash

module rm CMake
module load /users/jenkins/easybuild/daint/haswell/modules/all/CMake/3.12.4
module load cray-python/3.6.5.7

module swap PrgEnv-cray PrgEnv-gnu

export CXX=`which g++`
export CC=`which gcc`
export TMPDIR=`pwd`/temp
mkdir -p $TMPDIR