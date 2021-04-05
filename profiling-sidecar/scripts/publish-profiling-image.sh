#!/bin/bash

set -eo pipefail

display_info() {
  printf "Usage ./publish-profiling-image.sh [KERNEL_VERSION]\n"
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

docker push tiagonapoli/dotnet5.0-profiling-sidecar:kernel-$KERNEL_VERSION