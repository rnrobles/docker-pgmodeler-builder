# pgModeler Builder [![Docker Pulls](https://img.shields.io/docker/pulls/bqtran/pgmodeler-builder.svg?maxAge=2592000)](https://hub.docker.com/r/bqtran/pgmodeler-builder)

A [Docker](https://www.docker.com) container that allows you to build [pgModeler](https://pgmodeler.io/) with one
simple command.

# Features

This container currently produces binaries for Windows x86_64 only. This script is originally from (https://hub.docker.com/r/handcraftedbits/pgmodeler-builder) but updated for v1.0+, which now depends on QT 6.

# Usage

Simply run the `rnrobles87/pgmodeler-builder` image, specifying an output volume, mapped to the container
directory `/opt/pgmodeler` (where binaries will be saved) and the version to build (corresponding to a valid tag in the
[pgModeler Git repository](https://github.com/pgmodeler/pgmodeler) repository).  For example, to build pgModeler
version `1.0.1` and store the result in `/mnt/windows/pgmodeler`:

```bash
docker run -v /mnt/windows/pgmodeler:/opt/pgmodeler rnrobles87/pgmodeler-builder v1.0.2
```
windows local

```bash
docker run -v c:/mount:/opt/pgmodeler rnrobles87/pgmodeler-builder v1.0.2
```

If you run the command without specifying a version the container script will list all valid pgModeler versions.

Simply run the `pgmodeler.exe` executable stored in your output directory.  That's it!

# Image build

```bash
docker build -f ./Dockerfile-cc -t rnrobles87/pgmodeler-builder-cc .
docker build -f ./Dockerfile-deps1 -t rnrobles87/pgmodeler-builder-deps1 .
docker build -f ./Dockerfile-deps2 -t rnrobles87/pgmodeler-builder-deps2 .
docker build -f ./Dockerfile-postgres -t rnrobles87/pgmodeler-builder-postgres .
docker build -f ./Dockerfile -t rnrobles87/pgmodeler-builder .

```