#!/bin/bash

dotnet-trace collect -p 1 --providers Microsoft-DotNETCore-SampleProfiler -o ./profilings/trace.nettrace
chown 1000:1000 ./profilings/trace.nettrace
rm -rf ./profilings/trace.nettrace.gz
gzip -v ./profilings/trace.nettrace
du -sh ./profilings/*