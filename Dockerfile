# Build a docker image for the secondscreen application.
#
FROM       	ubuntu:12.04
MAINTAINER  pitrho

############################################################
# Install apt-get dependencies
############################################################
ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update -qq \
  && apt-get install -y \
    build-essential \
    libfuse-dev \
    fuse-utils \
    libcurl4-openssl-dev \
    libxml2-dev \
    mime-support \
    automake \
    libtool \
    wget \
    tar \
    python-dev \
    python2.7 \
    python-pip \
  && apt-get clean

############################################################
# Install s3fs
############################################################
RUN wget https://github.com/s3fs-fuse/s3fs-fuse/archive/v1.79.tar.gz
RUN tar zxvf v1.79.tar.gz
RUN cd s3fs-fuse-1.79 \
  && ./autogen.sh \
  && ./configure --prefix=/usr \
  && make && make install \
  && cd .. \
  && rm -rf s3fs-fuse-1.79 \
  && rm v1.79.tar.gz

############################################################
# Install pypiserver
############################################################
RUN pip install pypiserver passlib

############################################################
# Create run-as user and home directory
############################################################
ENV APPUSER rickybobby
ENV HOMEDIR /home/$APPUSER

RUN useradd $APPUSER -d $HOMEDIR

############################################################
# Create mount point for the S3 bucket
############################################################
ENV PACKAGES /packages
RUN mkdir $PACKAGES
RUN chown -R $APPUSER:$APPUSER $PACKAGES
RUN chown -R $APPUSER:$APPUSER $PACKAGES

############################################################
# Copy the run file to the home directory
############################################################
WORKDIR ${HOMEDIR}
ADD . $HOMEDIR

CMD []

USER ${APPUSER}
