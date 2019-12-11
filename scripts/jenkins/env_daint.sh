#!/bin/bash

module rm CMake
module load /users/jenkins/easybuild/daint/haswell/modules/all/CMake/3.12.4
module load cray-python/3.6.5.7

module swap PrgEnv-cray PrgEnv-gnu

export BOOST_ROOT=/project/c14/install/daint/boost/boost_1_67_0/

export CXX=`which g++`
export CC=`which gcc`
export TMPDIR=`pwd`/temp
mkdir -p $TMPDIR