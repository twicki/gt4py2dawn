import dawn4py
from dawn4py.serialization import SIR
from dawn4py.serialization import utils as sir_utils

from gt4py import gtscript
from gt4py import testing as gt_testing

import numpy as np
import itertools

import pytest


def test_setup():
    one = 1
    assert one == 1


def test_dawn4py_setup():
    access = sir_utils.make_field_access_expr("out", [1, 0, 0])
    assert access.cartesian_offset.i_offset == 1


@gtscript.function
def fwd_diff_op_xy(field):
    dx = field[1, 0, 0] - field[0, 0, 0]
    dy = field[0, 1, 0] - field[0, 0, 0]
    return dx, dy


def test_gt4py_setup():
    fwd_diff = gt_testing.global_name(singleton=fwd_diff_op_xy)
    assert fwd_diff.kind == "singleton"
