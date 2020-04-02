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


def test_compile_and_run():
    shape = (10, 10, 10)
    in_storage = gt4py.storage.ones(shape=shape, default_origin=(3, 3, 3), dtype=float, backend="gtx86")
    out_storage = gt4py.storage.zeros(shape=shape, default_origin=(3, 3, 3), dtype=float, backend="gtx86")
    copy_stencil(in_storage, out_storage)
    print(out_storage)
