FROM ubuntu:focal
# Install dependencies, including python3.7 from deadsnakes PPA
ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update
RUN apt-get install -y --no-install-recommends software-properties-common \
    && apt-get clean
RUN add-apt-repository ppa:deadsnakes/ppa
RUN apt-get install -y --no-install-recommends \
       build-essential bash git curl \
       g++ cmake make \
       python3.7 python3.7-dev python3.7-venv \
       libboost-dev \
    && apt-get clean

# Install pip for python 3.7 (is not packaged with it)
RUN curl https://bootstrap.pypa.io/get-pip.py | python3.7
RUN python3.7 -m pip install --upgrade pip

# Create python 3.7 venv that will be used at /env
RUN python3.7 -m venv env

# Install Dawn
ENV CMAKE_ARGS="-DPython3_FIND_VIRTUALENV=ONLY"
RUN git clone --depth 1 https://github.com/MeteoSwiss-APN/dawn.git /usr/src/dawn
RUN . /env/bin/activate && python3 -m pip install -e /usr/src/dawn/dawn

# Install GT4Py
RUN git clone -b fv3_validation --depth 1 https://github.com/eddie-c-davis/gt4py.git /usr/src/gt4py
RUN . env/bin/activate && python3 -m pip install -e /usr/src/gt4py
RUN (cd /usr/src/gt4py && . /env/bin/activate && python3 -m gt4py.gt_src_manager install)

# Run Tests
COPY test/ /usr/src/gt4py_integration_tests
RUN (cd /usr/src/gt4py_integration_tests && . /env/bin/activate && python3 -m pytest -v test_install.py test_integration.py test_copy.py)
