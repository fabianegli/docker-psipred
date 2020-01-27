# Dockerized PSIPRED

This repository provides a simple way to build and use PSIPRED on a local machine with Docker installed.

[PSIPRED](http://bioinf.cs.ucl.ac.uk/psipred/) is a secondary structure prediction tool and is used in many bioinformatics pipelines.

The Dockerfile specifies a Docker image that has PSIPRED installed and requires two volume mappings at runtime, the first for the sequence database used by blast and the second one with the fasta files to be predicted.
This mapping has the benefits that containers start up way faster and that the sequence databases can be used in multiple ways - It can even be concurrently used by multiple Docker containers and a natively installed software.

Wrapper scripts for `runpsipred` and `runpsipred_single` commands can be generated and installed so their usage then reflects that of a native installation.

The Docker container only contains the software - not the sequence databases. This is a deliberate choice to keep the Docker image small which is desirable for faster startup times of the docker containers and make it easy to run the software with different sequence databases.


# Usage

```
runpsipred_single example.fasta
```


# Requirements

* Docker
* make (GNU Make)

* Internet


# Installation

```
make build
make install PREFIX=bin
```

Options for `make`:

```
$ make help
 pull            Retrieves all requirements for the build.
 removesrc       Removes downloaded source files.
 build           Build the Docker image with PSIPRED.
 test            Runs a PSIPRED prediction.
 clean           Removes build artefacts.
 install         Installs wrapper scripts for PSIPRED.
 uninstall       Removes the Docker image.
 download        Download the sequence database.
 blastdb         Build the sequence database for BLAST.
 removedb        Removes the database files.
 installdb       Install the formated database.
 help            Display the help.
 tabularasa      [removesrc clean uninstall removedb].
```

After the Docker image is built, the following command can be used to run a container

```
docker run \
  --mount type=bind,source=/path/to/uniref90,target=/bioseqdb/ \
  --mount type=bind,source=/path/to/predictions/,target=/predictions/ \
  --rm -it psipred runpsipred /path/to/predictions/example.fasta
```

Other tools bundled in the legacy BLAST 2.2.26 and PSIPRED 4.02 can be analogous to the example above for `runpsipred`.

### PSIPRED 4.02
* runpsipred_single
* runpsipred
* chkparse
* psipass2
* psipred
* seq2mtx

### BLAST 2.2.26 (legacy)
* bl2seq
* blastclust
* copymat
* formatdb
* impala
* megablast
* seedtop
* blastall
* blastpgp
* fastacmd
* formatrpsdb
* makemat
* rpsblast


# License

This repository is licensed under the [GNU General Public License](http://www.gnu.org/licenses/gpl.html) as published by the Free Software Foundation; either version 3 of the License, or (at your option) any later version.

Some of the software and data downloaded and installed by the use of this software are distributed under other licenses.

Licenses of the software packages can be found in the downloads after `make pull` or [here](http://bioinfadmin.cs.ucl.ac.uk/downloads/psipred/LICENSE) for PSIPRED.

There is no license information available in the currently used blast download (recent version of the ncbi-blast package include a public domain notice).

The UniProt sequence database comes with a [Creative Commons Attribution (CC BY 4.0) License](http://creativecommons.org/licenses/by/4.0/)
