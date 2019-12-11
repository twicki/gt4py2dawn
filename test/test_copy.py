import gt4py
from gt4py import gtscript

import pytest


@gtscript.stencil(backend="dawn:gtmc")
def copy_stencil(in_field: gtscript.Field[float], out_field: gtscript.Field[float]):
    from __gtscript__ import computation, interval, PARALLEL

    with computation(PARALLEL), interval(...):
        out_field = in_field


def test_print():
    print(copy_stencil)
    shape = (10, 10, 10)
    in_storage = gt4py.storage.ones(shape=shape, default_origin=(3, 3, 3), dtype=float, backend="gtmc")
    out_storage = gt4py.storage.zeros(shape=shape, default_origin=(3, 3, 3), dtype=float, backend="gtmc")

    copy_stencil(in_storage, out_storage)

    print(out_storage)
