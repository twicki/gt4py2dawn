FROM jdahm/dawn-gcc9-env
RUN git clone --depth 1 -b dockerize https://github.com/jdahm/dawn.git /usr/src/dawn
RUN python -m pip install /usr/src/dawn/dawn
RUN git clone --depth 1 -b field_dimensions_fix https://github.com/jdahm/gt4py /usr/src/gt4py
RUN python -m pip install -e /usr/src/gt4py
RUN python /usr/src/gt4py/setup.py install_gt_sources
COPY test/ /usr/src/gt4py_integration_tests
RUN cd /usr/src/gt4py_integration_tests && python -m pytest -v test_install.py test_integration.py test_copy.py
