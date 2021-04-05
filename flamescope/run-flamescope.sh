#!/bin/bash

PROFILINGS_DIR=~/perf-profilings
mkdir -p $PROFILINGS_DIR
docker run --rm -it --mount type=bind,source=$PROFILINGS_DIR,target=/profiles -p 5050:5000 flamescope

