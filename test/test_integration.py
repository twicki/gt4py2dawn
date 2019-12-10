import numpy as np

from gt4py import gtscript
from gt4py import testing as gt_testing


# ---- Identity stencil ----
class TestIdentity(gt_testing.StencilTestSuite):
    """Identity stencil.
    """

    dtypes = (np.float_,)
    domain_range = [(1, 25), (1, 25), (1, 25)]
    backends = ["debug", "numpy"]
    symbols = dict(field_a=gt_testing.field(in_range=(-10, 10), boundary=[(0, 0), (0, 0), (0, 0)]))

    def definition(field_a):
        with computation(PARALLEL), interval(...):
            field_a = field_a  # TODO need 'pass'

    def validation(field_a, domain=None, origin=None):
        pass


# ---- Copy stencil ----
class TestCopy(gt_testing.StencilTestSuite):
    """Copy stencil.
    """

    dtypes = (np.float_,)
    domain_range = [(1, 25), (1, 25), (1, 25)]
    backends = ["debug", "numpy"]
    symbols = dict(
        field_a=gt_testing.field(in_range=(-10, 10), boundary=[(0, 0), (0, 0), (0, 0)]),
        field_b=gt_testing.field(in_range=(-10, 10), boundary=[(0, 0), (0, 0), (0, 0)]),
    )

    def definition(field_a, field_b):
        with computation(PARALLEL), interval(...):
            field_b = field_a

    def validation(field_a, field_b, domain=None, origin=None):
        field_b[...] = field_a
