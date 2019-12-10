#!/bin/bash

echo $BASEPATH_SCRIPT
# set -e

BASEPATH_SCRIPT="$(cd "$(dirname "${0}")"; pwd -P)/$(basename "${0}")"
SCRIPT=`basename $0`

function help {
  echo -e "Basic usage: $SCRIPT "\\n
  echo -e "The following switches are recognized. $OFF "
  echo -e "-h Shows this help"
  echo -e "-c clears the installed dependencies and the virtual environment"
  echo -e "-i installs all the dependencies and sets up a venv"
  exit 1
}

function clear {
	#################### cleanup  ####################
	rm -rf ${base_dir}/build
}

function install_step {
	mkdir -p ${base_dir}/build
	cd ${base_dir}/build
	#################### cleanup  ####################
	# rm -rf gt4py dawn .project_venv

	# set up the virtual environment
	python -m venv .project_venv
	source .project_venv/bin/activate
	pip install wheel

	#################### Installation of GT4py  ####################
	if [ -z ${GT4PY_BRANCH+x} ]; then
 		echo "GT4PT branch not set, using the default"
		git clone git@github.com:twicki/gt4py.git -b fix
	else
		git clone git@github.com:twicki/gt4py.git -b ${GT4PY_BRANCH}
	fi
	pip install ./gt4py -v
	python ./gt4py/setup.py install_gt_sources

	# TODO: change to this once we have it merged to master
	# git clone git@github.com:MeteoSwiss-APN/dawn.git
	if [ -z ${DAWN_BRANCH+x} ]; then
 		echo "dawn branch not set, using the default"
		git clone git@github.com:egparedes/dawn.git -b add_python_bindings
	else
		git clone git@github.com:egparedes/dawn.git -b ${DAWN_BRANCH}
	fi	
	pip install -e ./dawn/dawn -v
}


base_dir=$(dirname "$(dirname "$(dirname "${BASEPATH_SCRIPT}")")")
while getopts hcig:d: flag; do
  case $flag in
    h)
      help
      ;;
    c)
		clear
		;;
	g)
		GT4PY_BRANCH=$OPTARG
		;;
	d)
		DAWN_BRANCH=$OPTARG
		;;
    i)
		install_step
		;;
    \?) #unrecognized option - show help
      echo -e \\n"Option -${BOLD}$OPTARG${OFF} not allowed."
      help
      ;;
  esac
done

source ${base_dir}/build/.project_venv/bin/activate

# Testing of the dawn installation
# TODO: ask Enrique, seems strage

# Testing of the GT4Py installation
cd ${base_dir}/build/gt4py


# test if the setup is ok and all the modules are loaded properly
cd ${base_dir}/test
pytest -v test_install.py test_integration.py
