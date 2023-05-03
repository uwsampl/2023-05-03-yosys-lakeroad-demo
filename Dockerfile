FROM ubuntu:22.04

ENV LAKEROAD_DIR=/root/yosys/lakeroad

RUN apt-get update
# Get add-apt-repository
RUN apt install -y software-properties-common
# Add PPA for Racket
RUN add-apt-repository ppa:plt/racket
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y \
  bison \
  build-essential \
  cmake \
  curl \
  clang \
  flex \
  gawk \
  git \
  graphviz \
  libboost-filesystem-dev\
  libboost-python-dev \
  libboost-system-dev \
  libffi-dev \
  libreadline-dev \
  pkg-config \
  python3 \
  racket \
  tcl-dev \
  xdot\
  zlib1g-dev

# Build Yosys.
WORKDIR /root
# Yosys build depends on it being a git repo.
ADD . .
WORKDIR /root/yosys
RUN make config-clang && make -j$(nproc)


# Build and install latest boolector.
WORKDIR /root
RUN git clone https://github.com/boolector/boolector \
  && cd boolector \
  && git checkout 3.2.2 \
  && ./contrib/setup-lingeling.sh \
  && ./contrib/setup-btor2tools.sh \
  && ./configure.sh \
  && cd build \
  && make -j$(nproc) install

# raco (Racket) dependencies
# First, fix https://github.com/racket/racket/issues/2691
RUN raco setup --doc-index --force-user-docs
RUN raco pkg install --deps search-auto --batch \
  fmt \
  rosette \
  yaml

# Compile Lakeroad.
RUN raco make /root/yosys/lakeroad/bin/main.rkt

WORKDIR /root