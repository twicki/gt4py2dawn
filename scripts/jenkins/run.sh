#!/bin/bash

set -e

BASEPATH_SCRIPT="$(cd "$(dirname "${0}")"; pwd -P)/$(basename "${0}")"
SCRIPT=`basename $0`

function help {
  echo -e "Basic usage: $SCRIPT "\\n
  echo -e "The following switches are recognized. $OFF "
  echo -e "-h Shows this help"
  echo -e "-c clears the installed dependencies and the virtual environment"
  echo -e "-i installs all the dependencies and sets up a venv"
  echo 
  exit 1
}

function clear {
	#################### cleanup  ####################
	rm -rf ${base_dir}/build
}

function install_step {
	mkdir -p ${base_dir}/build
	cd ${base_dir}/build

	# set up the virtual environment
	python -m venv dawn_venv
	source dawn_venv/bin/activate
	python -m pip install --upgrade pip
	python -m pip install wheel

	if [ -z ${DAWN_BRANCH+x} ]; then
 		echo "dawn branch not set, using the default"
		git clone git@github.com:MeteoSwiss-APN/dawn.git
	else
		# git clone git@github.com:MeteoSwiss-APN/dawn.git -b ${DAWN_BRANCH}
		git clone git@github.com:twicki/dawn.git -b ${DAWN_BRANCH}
	fi	
	python -m pip install -e ./dawn/dawn -v

	#################### Installation of GT4py  ####################
	if [ -z ${GT4PY_BRANCH+x} ]; then
 		echo "GT4PT branch not set, using the default"
		git clone git@github.com:twicki/gt4py.git -b fix
	else
		git clone git@github.com:twicki/gt4py.git -b ${GT4PY_BRANCH}
	fi
	python -m pip install -e ./gt4py -v
	# jenkins can't do this and it's unclear why. This is why we do it manually here
	# python ./gt4py/setup.py install_gt_sources
	mkdir -p ${base_dir}/build/gt4py/src/gt4py/_external_src/
	git clone --depth 1 -b release_v1.1 https://github.com/GridTools/gridtools.git ${base_dir}/build/gt4py/src/gt4py/_external_src/gridtools

}


base_dir=$(dirname "$(dirname "$(dirname "${BASEPATH_SCRIPT}")")")
while getopts hcig:d:l flag; do
  case $flag in
    h)
      help
      ;;
    c)
		DO_CLEAR_STEP="ON"
		;;
	g)
		GT4PY_BRANCH=$OPTARG
		;;
	d)
		DAWN_BRANCH=$OPTARG
		;;
    i)
		DO_INSTALL_STEP="ON"
		;;
	l)
		LOCAL_SETUP="ON"
		;;
    \?) #unrecognized option - show help
      echo -e \\n"Option -${BOLD}$OPTARG${OFF} not allowed."
      help
      ;;
  esac
done


if [ -z ${LOCAL_SETUP+x} ]; then
	BASEPATH_SCRIPT=$(dirname "${0}")
	source ${BASEPATH_SCRIPT}/machine_env.sh
	source ${BASEPATH_SCRIPT}/env_${myhost}.sh

	if [ -z ${myhost+x} ]; then
	echo "myhost is unset"
	exit 1
	fi
fi

# Create a temporary directory for pip
export TMPDIR=${base_dir}/temp
mkdir -p $TMPDIR

if [ -z ${DO_CLEAR_STEP+x} ]; then
	echo " no clear step specified"
else
	clear
fi

if [ -z ${DO_INSTALL_STEP+x} ]; then
	echo " no install step required"
else
	install_step
fi

source ${base_dir}/build/dawn_venv/bin/activate

# Testing of the dawn installation
cd ${base_dir}/build/dawn/dawn/examples/python
bash run.sh
python -m pytest -v ${base_dir}/build/dawn/dawn/test/unit-test/test_dawn4py/

# Testing of the GT4Py installation
cd ${base_dir}/build/gt4py
# currently broken, will come later


# test if the setup is ok and all the modules are loaded properly
cd ${base_dir}/test
python -m pytest -v test_install.py test_integration.py test_copy.py


rm -rf ${TMPDIR}