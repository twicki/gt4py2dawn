import dawn4py
from dawn4py.serialization import SIR
from dawn4py.serialization import utils as sir_utils

import gt4py as gt

import numpy as np
import itertools

import pytest


def test_setup():
	one =1
	assert(one == 1)

def test_dawn4py_setup():
	access = sir_utils.make_field_access_expr("out", [1, 0, 0])
	assert(access.cartesian_offset.i_offset == 1)

def test_gt4py_setup():
	grid = gt.Grid()
