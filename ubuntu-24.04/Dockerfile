ARG DOCKER_HUB=docker.io
FROM ${DOCKER_HUB}/library/ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive
ENV INSTALL_DIR=/p4-dev
ENV PYTHON_ENV=${INSTALL_DIR}/p4dev-python-venv

WORKDIR ${INSTALL_DIR}

RUN apt-get update && apt-get install -y --fix-missing\
    autoconf \
    automake \
    libtool \
    curl \
    make \
    g++ \
    unzip \
    pkg-config \
    python3 \
    python3-pip \
    python3-venv \
    cmake \
    libreadline-dev \
    valgrind \
    libtool-bin \
    libboost-dev \
    libboost-system-dev \
    libboost-thread-dev \
    libboost-iostreams-dev \
    libboost-graph-dev \
    libgflags-dev \
    net-tools \
    git \
    wget \
	vim \
	dos2unix \
    && rm -rf /var/lib/apt/lists/*

RUN python3 -m venv ${PYTHON_ENV}
ENV PATH="${PYTHON_ENV}/bin:${PATH}"

RUN pip3 install protobuf grpcio psutil crcmod scapy==2.5.0

RUN apt-get update && apt-get install -y software-properties-common
RUN add-apt-repository universe && \
    add-apt-repository multiverse && \
    apt-get update

RUN apt-get install -y \
    libgrpc-dev \
    libgrpc++-dev \
    libprotobuf-dev \
    protobuf-compiler \
    protobuf-compiler-grpc

WORKDIR ${INSTALL_DIR}
COPY install_from_tar_or_git.sh ./
COPY *.tar.* ./

# Collect P4-dev repos
RUN ./install_from_tar_or_git.sh PI.tar.gz https://github.com/p4lang/PI PI
WORKDIR ${INSTALL_DIR}/PI
RUN git submodule update --init --recursive
WORKDIR ${INSTALL_DIR}
RUN ./install_from_tar_or_git.sh behavioral-model.tar.gz https://github.com/p4lang/behavioral-model.git behavioral-model
RUN ./install_from_tar_or_git.sh p4c.tar.gz https://github.com/p4lang/p4c p4c
WORKDIR ${INSTALL_DIR}/p4c
RUN git submodule update --init --recursive
WORKDIR ${INSTALL_DIR}
RUN ./install_from_tar_or_git.sh mininet.tar.gz https://github.com/mininet/mininet mininet
RUN ./install_from_tar_or_git.sh ptf.tar.gz https://github.com/p4lang/ptf ptf
RUN ./install_from_tar_or_git.sh p4runtime-shell.tar.gz https://github.com/p4lang/p4runtime-shell p4runtime-shell
RUN ./install_from_tar_or_git.sh tutorials.tar.gz https://github.com/p4lang/tutorials tutorials

WORKDIR ${INSTALL_DIR}/PI
RUN ./autogen.sh && \
    ./configure --with-proto --without-interal-rpc --without-cli --without-bmv2 --with-python_prefix=${PYTHON_ENV}
RUN make -j${nproc}
RUN make install
RUN make clean
WORKDIR ${INSTALL_DIR}

WORKDIR ${INSTALL_DIR}/behavioral-model
COPY patches/behavioral-model-support-fedora.patch ./
COPY patches/behavioral-model-support-venv.patch ./
RUN patch -p1 < behavioral-model-support-fedora.patch && \
    patch -p1 < behavioral-model-support-venv.patch
RUN find . -type f -name "*.sh" -exec sed -i 's/sudo //g' {} +
RUN ./install_deps.sh    
RUN --mount=type=tmpfs,target=build \
    cd build && cmake -DWITH_PI=on -DWITH_THRIFT=ON -DENABLE_MODULES=on .. && \
    make -j8 && make install/strip
WORKDIR ${INSTALL_DIR}

WORKDIR ${INSTALL_DIR}/p4c
RUN mkdir build && cd build && cmake .. -DCMAKE_BUILD_TYPE=Release -DENABLE_TEST_TOOLS=ON
WORKDIR ${INSTALL_DIR}/p4c/build
RUN make -j4
RUN make install/strip
RUN ldconfig
WORKDIR ${INSTALL_DIR}
RUN rm -rf p4c/build

#RUN apt-get update && apt-get install -y mininet && \
#    rm -rf /var/lib/apt/lists/*

WORKDIR ${INSTALL_DIR}
# 2024-Sep-18
RUN rm -rf mininet
RUN mkdir mininet && tar -xaf mininet.tar.gz -C ./mininet
WORKDIR ${INSTALL_DIR}/mininet
RUN sed -i 's/sudo //g' ./util/install.sh
RUN sed -i 's/$install /eval $install /g' ./util/install.sh
RUN sed -i 's/$install /eval $install /g' ./util/install.sh
RUN PYTHON=python3 ./util/install.sh -nw
WORKDIR ${INSTALL_DIR}

WORKDIR ${INSTALL_DIR}/ptf
RUN pip3 install .
WORKDIR ${INSTALL_DIR}

WORKDIR ${INSTALL_DIR}/p4runtime-shell
COPY patches/p4runtime-shell-2023-changes.patch ./
RUN patch -p1 < p4runtime-shell-2023-changes.patch
RUN pip3 install .
WORKDIR ${INSTALL_DIR}

COPY utils ./utils
RUN find . -type f -name "*.sh" -exec sed -i 's/sudo //g' {} +
RUN find . -type f -name "*Makefile" -exec sed -i 's/sudo //g' {} +

RUN echo "source ${PYTHON_ENV}/bin/activate" > p4setup.sh
RUN echo "export PATH=\"${INSTALL_DIR}/utils:${INSTALL_DIR}/behavioral-model/tools:/usr/local/bin:\$PATH\"" >> p4setup.sh
RUN echo "export P4_EXTRA_SUDO_OPTS=\"PROTOCOL_BUFFERS_PYTHON_IMPLEMENTATION=python\"" >> p4setup.sh
RUN chmod +x p4setup.sh
RUN echo "source ${INSTALL_DIR}/p4setup.sh" >> ~/.bashrc

CMD ["/bin/bash", "-c", "source /p4-dev/p4setup.sh && bash && /p4-dev/utils/p4-environment-info.sh"]
