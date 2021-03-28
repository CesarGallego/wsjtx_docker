FROM ubuntu:latest

ENV TZ 'Europe/Madrid'
RUN echo $TZ > /etc/timezone && \
  apt-get update && apt-get upgrade -y && \
  apt-get install -y tzdata && \
  rm /etc/localtime && \
  ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && \
  dpkg-reconfigure -f noninteractive tzdata && \
  apt-get install -y autoconf automake libtool cmake git && \
  apt-get clean
RUN apt-get install -y build-essential gfortran asciidoctor libfftw3-dev qtdeclarative5-dev texinfo libqt5multimedia5 libqt5multimedia5-plugins qtmultimedia5-dev libusb-1.0.0-dev libqt5serialport5-dev asciidoc libudev-dev

RUN mkdir /hamlib 
WORKDIR /hamlib
RUN git clone git://git.code.sf.net/u/bsomervi/hamlib src
RUN cd src && git checkout integration && ./bootstrap && mkdir ../build && cd ../build && \
 ../src/configure --prefix=$HOME/hamlib-prefix    --disable-shared --enable-static    --without-cxx-binding --disable-winradio    CFLAGS="-g -O2 -fdata-sections -ffunction-sections"  LDFLAGS="-Wl,--gc-sections" && \
 make -j4 &&  make install-strip && cd ../../

RUN DEBIAN_FRONTEND=noninteractive apt-get install -y qttools5-dev \
libboost-all-dev locales

WORKDIR /
RUN apt-get install -y wget && wget https://physics.princeton.edu/pulsar/k1jt/wsjtx-2.3.1.tgz
RUN tar vxfz wsjtx-2.3.1.tgz
WORKDIR wsjtx-2.3.1
RUN echo "en_US.UTF-8 UTF-8" > /etc/locale.gen && locale-gen
RUN mkdir build && \
  mkdir output && \ 
  cd build && cmake -D CMAKE_PREFIX_PATH=/root/hamlib-prefix -D \
  CMAKE_INSTALL_PREFIX=/wsjtx-2.3.1/output ../ && \
  cmake --build . -- -j2 && \
  cmake --build . --target install

ENTRYPOINT ["/wsjtx-2.3.1/output/bin/wsjtx"]
