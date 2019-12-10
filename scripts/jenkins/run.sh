#!/bin/bash

echo $BASEPATH_SCRIPT
# set -e

BASEPATH_SCRIPT="$(cd "$(dirname "${0}")"; pwd -P)/$(basename "${0}")"
SCRIPT=`basename $0`

function help {
  echo -e "Basic usage: $SCRIPT "\\n
  echo -e "The following switches are recognized. $OFF "
  echo -e "-h Shows this help"
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
	python3 -m venv .project_venv
	source .project_venv/bin/activate
	pip install wheel

	#################### Installation of GT4py  ####################
	git clone git@github.com:twicki/gt4py.git -b fix
	pip install ./gt4py -v
	python3 gt4py/setup.py install_gt_sources

	# TODO: change to this once we have it merged to master
	# git clone git@github.com:MeteoSwiss-APN/dawn.git
	git clone git@github.com:egparedes/dawn.git -b add_python_bindings
	pip install -e ./dawn/dawn -v
}


base_dir=$(dirname "$(dirname "$(dirname "${BASEPATH_SCRIPT}")")")
while getopts hci flag; do
  case $flag in
    h)
      help
      ;;
    c)
		clear
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

cd ${base_dir}/test
pytest -v test.py