FROM docker.io/ubuntu:24.04

RUN apt-get update && apt-get install -y wget git python3 python3-venv
RUN cd /tmp && pwd &&\
    wget https://repo.radeon.com/amdgpu-install/6.3.4/ubuntu/noble/amdgpu-install_6.3.60304-1_all.deb && ls &&\
    apt-get install -y ./amdgpu-install_6.3.60304-1_all.deb && \
    apt-get update && \
    apt-get install -y rocm

RUN cd /opt && python3 -m venv vllmenv &&\
    . ./vllmenv/bin/activate &&\
    pip3 install ninja cmake wheel pybind11 amdsmi setuptools setuptools_scm &&\
    pip3 install --no-cache-dir --pre torch>=2.6 torchvision torchaudio --index-url https://download.pytorch.org/whl/nightly/rocm6.3

ADD ./patch/triton.patch /opt

RUN cd /opt &&\
    . ./vllmenv/bin/activate &&\
    git clone https://github.com/triton-lang/triton.git && cd triton &&\
    git checkout 58f7ef69d27274c620199eadaaa0f33075d86404 &&\
    patch -p1 < /opt/triton.patch && \
    cd python && pip3 install -e .

ADD ./patch/vllm_0.7.3.patch /opt

RUN cd /opt &&\
    . ./vllmenv/bin/activate &&\
    git clone https://github.com/vllm-project/vllm.git && cd vllm &&\
    git checkout refs/tags/v0.7.3 &&\
    patch -p1 < /opt/vllm_0.7.3.patch && \
    pip3 install "aiohttp==3.11.13" && \
    pip3 uninstall "httpx>=1" && \
    pip3 install "httpx<1" && \
    python3 setup.py develop

RUN cd /opt &&\
    . ./vllmenv/bin/activate &&\
    pip3 uninstall -y "numpy>=2"

ENV PYTHONPATH=/opt/triton/python:$PYTHONPATH
ENV VIRTUAL_ENV /opt/vllmenv
ENV PATH /opt/vllmenv/bin:$PATH

