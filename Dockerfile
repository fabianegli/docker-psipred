############################################################
# Dockerfile to build the docker-psipred Docker image
############################################################
# Depends on local data and software to avoid repeated
# downloads of large volumes of data. To allow the software
# to tbe accessed form within the docker container bind the
# required-for-build folder to the docker container:
# --mount type=bind,source="$(pwd)"/required-for-build,target=/required-for-build
#
# To use the date for the data
# --mount type=bind,source="$(pwd)"/data,target=/data
#
# © 2019 Fabian Egli <https://github.com/fabianegli>
############################################################
FROM ubuntu:18.04 as blastbuild

################## BEGIN INSTALLATION ######################
# tcsh is required by the runpsipred and runpsipred_single scripts.
# vim is not necessary, but convenient for interactive troubleshooting
RUN apt-get -y update \
  && apt-get -y upgrade \
  && apt-get install -y apt-utils \
  && apt-get -y autoremove \
  && apt-get -y install wget \
  && apt-get -y install curl \
  && apt-get -y install build-essential \
  && apt-get -y install tcsh \
  && apt-get -y install vim

ADD blast-2.2.26-x64-linux.tar.gz /
# Add blast binaries to path
ENV PATH="/blast-2.2.26/bin:${PATH}"

ADD psipred.4.02.tar.gz /
# make and install psipred binaries
RUN cd /psipred/src && make && make install
ENV PATH="/psipred:/psipred/bin:${PATH}"

# Set paths in scripts
RUN  sed -i "s/execdir = \.\/bin/execdir = \/psipred\/bin/" /psipred/runpsipred \
  && sed -i "s/execdir = \.\/bin/execdir = \/psipred\/bin/" /psipred/runpsipred_single \
  && sed -i "s/datadir = \.\/data/datadir = \/psipred\/data/" /psipred/runpsipred \
  && sed -i "s/datadir = \.\/data/datadir = \/psipred\/data/" /psipred/runpsipred_single \
  && sed -i "s/ncbidir = \/usr\/local\/bin/ncbidir = \/blast-2.2.26\/bin/" /psipred/runpsipred \
  && sed -i "s/dbname = uniref90/dbname = \/bioseqdb\/uniref90.fasta/" /psipred/runpsipred

WORKDIR /predictions
