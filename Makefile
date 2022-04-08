# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# Makefile for PSIPRED-Docker                                         #
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# @2020 Fabian Egli                                                   #
# License: GNU GENERAL PUBLIC LICENSE Version 3 or any later version  #
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

.PHONY: pull removesrc build test clean install uninstall download \
	      blastdb removedb installdb uninstalldb help tabularasa

help:
	@echo " pull            Retrieves all requirements for the build."
	@echo " removesrc       Removes downloaded source files."
	@echo " build           Build the Docker image with PSIPRED."
	@echo " test            Runs a PSIPRED prediction."
	@echo " clean           Removes build artefacts."
	@echo " install         Installs psipred_docker."
	@echo " uninstall       Removes the Docker image."
	@echo " download        Download the sequence database."
	@echo " blastdb         Build the sequence database for BLAST."
	@echo " removedb        Removes the database files."
	@echo " installdb       Install the formated database."
	@echo " uninstalldb     Removes the installed database files."
	@echo " help            Display the help."
	@echo " tabularasa      [clean uninstall removedb removesrc]."

IMAGE_NAME ?= psipred
# IMAGE_TAG ?= $PSIPRED_VERSION
PD_TOOLS ?= runpsipred_single runpsipred
PREFIX ?= /usr/local/bin

SEQDB ?= uniref90
FASTA := $(SEQDB).fasta
FASTAGZ := $(SEQDB).fasta.gz
BIOSEQDB_PATH ?= bioseqdb
PREFIX_BIOSEQDB ?= $(HOME)/$(BIOSEQDB_PATH)/$(SEQDB)

PREFIX_PREDICTIONS ?= $(HOME)/predictions

SCRIPT_HEADER = \#!/usr/bin/env bash\n\#\n\# $$PD_TOOL - a wrapper script for invoking $$PD_TOOL from within a Docker image\n\#\n\# @2020 Fabian Egli\n\# License: GNU GENERAL PUBLIC LICENSE Version 3 or any later version\n

build: pull runner
	@mkdir -p build
	@cp required-for-build/psipred.4.02.tar.gz build
	@cp required-for-build/blast-2.2.26-x64-linux.tar.gz build
	@cp Dockerfile build
	@cd build && docker build -t $(IMAGE_NAME) .

pull:
	@mkdir -p required-for-build
	@wget -c -N http://bioinfadmin.cs.ucl.ac.uk/downloads/psipred/psipred.4.02.tar.gz -P required-for-build
	@wget -c -N ftp://ftp.ncbi.nlm.nih.gov/blast/executables/legacy.NOTSUPPORTED/2.2.26/blast-2.2.26-x64-linux.tar.gz -P required-for-build

runner:
	@echo "Writing wrapper scipts:"
	@for PD_TOOL in $(PD_TOOLS); do \
		echo " - $$PD_TOOL"; \
		echo "$(SCRIPT_HEADER)" > $$PD_TOOL ; \
		echo "docker run \\\\" >> $$PD_TOOL ; \
		echo "  --mount type=bind,source=$(PREFIX_BIOSEQDB),target=/bioseqdb/ \\\\" >> $$PD_TOOL; \
		echo "  --mount type=bind,source=$(PREFIX_PREDICTIONS),target=/predictions/ \\\\" >> $$PD_TOOL; \
		echo "  --rm -it $(IMAGE_NAME) $$PD_TOOL \044(basename \044{1})" >> $$PD_TOOL; \
	done

test:
	@for PD_TOOL in $(PD_TOOLS); do \
		sh $$PD_TOOL $(PREFIX_PREDICTIONS)/example.fasta && echo "TEST for $$PD_TOOL was successful." || echo "TEST for $$PD_TOOL failed."; \
	done

clean:
	rm -rf build
	rm $(PD_TOOLS)

removedsrc:
	rm -r required-for-build

install:
	@mkdir -p $(PREFIX)
	@cp $(PD_TOOLS) $(PREFIX)/
	@for PD_TOOL in $(PD_TOOLS); do \
		chmod +x $(PREFIX)/$$PD_TOOL; \
	done
	@mkdir -p $(PREFIX_PREDICTIONS)

uninstall:
	@for PD_TOOL in $(PD_TOOLS); do \
		rm $(PREFIX)/$$PD_TOOL; \
	done

download:
	@mkdir -p $(BIOSEQDB_PATH)
	@wget -c -N ftp://ftp.expasy.org/databases/uniprot/current_release/uniref/uniref90/RELEASE.metalink -P $(BIOSEQDB_PATH)
	@wget -c -N ftp://ftp.expasy.org/databases/uniprot/current_release/uniref/uniref90/$(FASTAGZ) -P $(BIOSEQDB_PATH)

formatdb:
	# format database for blast
	@if [ ! -f $(BIOSEQDB_PATH)/$(FASTA) ]; then gzip -d -k $(BIOSEQDB_PATH)/$(FASTAGZ); fi
	docker run -it --rm \
	  --mount type=bind,source=$(realpath $(BIOSEQDB_PATH)),target=/$(BIOSEQDB_PATH)/ \
	  $(IMAGE_NAME) /bin/bash -c \
	  "formatdb -p T -o T -t $(SEQDB) -i /$(BIOSEQDB_PATH)/$(FASTA)"

installdb:
	# Because the database is considerably large, it is moved - not coppied.
	mkdir -p $(PREFIX_BIOSEQDB)
	mv $(BIOSEQDB_PATH)/* $(PREFIX_BIOSEQDB)/ && rmdir $(BIOSEQDB_PATH)

uninstalldb:
	rm -r $(PREFIX_BIOSEQDB)/

removedb:
	rm -rf $(BIOSEQDB_PATH)

tabularasa: clean uninstall removedb removedsrc
	@echo "NB: The installed database is not removed by tabularasa."
	@echo "    Remove it with 'make uninstalldb' or by running:"
	@echo "    rm -r $(PREFIX_BIOSEQDB)/"
