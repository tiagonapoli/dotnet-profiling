#!/bin/bash

set -eo pipefail

display_info() {
  printf "Usage ./build-profiling-container.sh [KERNEL_VERSION]\n"
  printf "  KERNEL_VERSION: Kernel version of the 'perf' tool to be used\n"
  printf "  -h: Show this message\n"
  exit 0
}

while getopts "h" OPT; do
  case "$OPT" in
    "k") KERNEL_VERSION=$OPTARG;;
    "h") display_info;;
    "?") display_info;;
  esac 
done

KERNEL_VERSION="v5.8.1"
if [[ ! "$1" == "" ]]; then
    KERNEL_VERSION=$1
fi

docker build \
    -t tiagonapoli/dotnet5.0-profiling-sidecar:kernel-$KERNEL_VERSION \
    -f ./images/dotnet-profiling-sidecar.dockerfile \
    --build-arg LINUX_KERNEL_VERSION=$KERNEL_VERSION \
    ./src