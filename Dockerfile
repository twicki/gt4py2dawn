FROM jdahm/dawn-gcc9-env
RUN git clone --depth 1 https://github.com/MeteoSwiss-APN/dawn.git /usr/src/dawn
RUN python -m pip install /usr/src/dawn/dawn
RUN git clone --depth 1 -b new_dawn https://github.com/egparedes/gt4py /usr/src/gt4py
RUN python -m pip install -e /usr/src/gt4py
RUN cd /usr/src/gt4py && python -m gt4py.gt_src_manager install
COPY test/ /usr/src/gt4py_integration_tests
RUN cd /usr/src/gt4py_integration_tests && python -m pytest -v test_install.py test_integration.py test_copy.py
