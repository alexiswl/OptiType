#################################################################
# Dockerfile
#
# Version:          1.0
# Software:         OptiType
# Software Version: 1.3
# Description:      Accurate NGS-based 4-digit HLA typing
# Website:          https://github.com/FRED-2/OptiType/
# Tags:             Genomics
# Provides:         OptiType 1.3
# Base Image:       biodckr/biodocker
# Build Cmd:        docker build --rm -t fred2/opitype .
# Pull Cmd:         docker pull fred2/optitype
# Run Cmd:          docker run -v /path/to/file/dir:/data fred2/optitype
#################################################################

ARG LATEST_VERSION="v1.3.4"

# Source Image
FROM biocontainers/biocontainers:latest

################## BEGIN INSTALLATION ###########################
USER root

# install
RUN apt-get update && apt-get install -y software-properties-common \
&& apt-get update && apt-get install -y \
     python-pip \
     python-sphinx \
     python2.7 \
     gcc-4.9 \
     g++-4.9 \
     coinor-cbc \
     zlib1g-dev \
     libbz2-dev \
     libboost-dev \
&& update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-4.9 60 --slave /usr/bin/g++ g++ /usr/bin/g++-4.9 \
&& rm -rf /var/lib/apt/lists/* \
&& apt-get clean \
&& apt-get purge \
&& pip install --upgrade pip

#HLA Typing
#OptiType dependecies
RUN curl -O https://support.hdfgroup.org/ftp/HDF5/current18/bin/hdf5-1.8.21-Std-centos7-x86_64-shared_64.tar.gz \
    && tar -xvf hdf5-1.8.21-Std-centos7-x86_64-shared_64.tar.gz \
    && mv     hdf5/bin/* /usr/local/bin/ \
    && mv     hdf5/lib/* /usr/local/lib/ \
    && mv     hdf5/include/* /usr/local/include/ \
    && mv     hdf5/share/* /usr/local/share/ \
    && rm -rf hdf5/ \
    && rm -f  hdf5-1.8.21-Std-centos7-x86_64-shared_64.tar.gz

ENV LD_LIBRARY_PATH "/usr/local/lib:$LD_LIBRARY_PATH"
ENV HDF5_DIR "/usr/local/"

#installing razers3
RUN git clone https://github.com/seqan/seqan.git seqan-src \
    && cd seqan-src \
    && cmake -DCMAKE_BUILD_TYPE=Release \
    && make razers3 \
    && cp bin/razers3 /usr/local/bin \
    && cd .. \
    && rm -rf seqan-src

#installing optitype form git repository (version Dec 09 2015) and wirtig config.ini
RUN mkdir /usr/local/bin/OptiType/
COPY ./ /usr/local/bin/OptiType/
ENV PATH="/usr/local/bin/OptiType:$PATH"

# Install modules locally
RUN pip2 install --upgrade pip \
    && pip2 install \
         numpy \
         pyomo \
         pysam \
         matplotlib \
         tables \
         pandas \
         future

# Change user to back to biodocker
USER biodocker

# Change workdir to /data/
WORKDIR /data/

##################### INSTALLATION END ##########################

# File Author / Maintainer
MAINTAINER Benjamin Schubert <schubert@informatik.uni-tuebingen.de>
