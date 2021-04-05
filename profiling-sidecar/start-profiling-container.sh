#!/bin/bash

set -euo pipefail

display_info() {
  printf "Usage ./start-profiling-container.sh [OPT]\nOptions are:\n"
  printf "  -c (ID): ID of the container with the process to profile\n"
  printf "  -k (ARG): Kernel version of the 'perf' tool to be used\n"
  printf "  -s: Add coreclr symbols to target container\n"
  printf "  -b: Build profiling sidecar image\n"
  printf "  -h: Show this message\n"
  exit 0
}

CONTAINER_ID="$(sudo docker container ls -q)"
KERNEL_VERSION="v5.8.1"
ADD_CORECLR_SYMBOLS="false"
BUILD_PROFILER_IMAGE="false"
USE_DEVICE_MAPPER_TO_BIND_TMP="false"
ENTRYPOINT="/bin/bash"
while getopts "c:k:e:sbdh" OPT; do
  case "$OPT" in
    "c") CONTAINER_ID=$OPTARG;;
    "k") KERNEL_VERSION=$OPTARG;;
    "s") ADD_CORECLR_SYMBOLS="true";;
    "b") BUILD_PROFILER_IMAGE="true";;
    "d") USE_DEVICE_MAPPER_TO_BIND_TMP="true";;
    "e") ENTRYPOINT=$OPTARG;;
    "h") display_info;;
    "?") display_info;;
  esac 
done

if [ "$BUILD_PROFILER_IMAGE" == "true" ]; then
  make build-profiler-image KERNEL_VERSION=$KERNEL_VERSION
fi

HOST_PROFILINGS_DIR=~/perf-profilings
mkdir -p $HOST_PROFILINGS_DIR

echo "> Using perf from Linux's kernel $KERNEL_VERSION..."

echo -e "> The container to be attached will be the following: \n"
sudo docker container ls -f "id=$CONTAINER_ID"

if [ "$ADD_CORECLR_SYMBOLS" == "true" ]; then
  echo -e "\n> Downloading coreclr symbols on target container"
  ./scripts/download-net-symbols.sh -c $CONTAINER_ID
fi

echo -e "\n> The following bind mounts will be created:"
echo -e "  HOST                 CONTAINER"
echo -e "- /tmp              -> /tmp"
echo -e "- ~/perf-profilings -> /workspace/profilings"
echo -e "\n"

TARGET_CONTAINER_TMP_DIR="/tmp"

if [ "$BUILD_PROFILER_IMAGE" == "true" ]; then
  make build-profiler-image KERNEL_VERSION=$KERNEL_VERSION
fi

if [ "$USE_DEVICE_MAPPER_TO_BIND_TMP" == "true" ]; then
  DEVICEMAPPER_ID=$(sudo docker inspect --format {{.GraphDriver.Data.DeviceName}} $CONTAINER_ID)
  DEVICE_MAPPER_DIR=${DEVICEMAPPER_ID##*-}
  echo -e "> Device mapper dir $DEVICE_MAPPER_DIR"

  OTHER_CONTAINER_DEVICE_MAPPER_ID=$DEVICE_MAPPER_DIR
  TARGET_CONTAINER_TMP_DIR="/var/lib/docker/devicemapper/mnt/$OTHER_CONTAINER_DEVICE_MAPPER_ID/rootfs/tmp"
  echo -e "Target container overlay upperDir contents:"
  sudo ls $TARGET_CONTAINER_TMP_DIR
fi

sudo docker run -it \
  --rm \
  --privileged \
  --pid=container:$CONTAINER_ID \
  --mount type=bind,source=$TARGET_CONTAINER_TMP_DIR,target=/tmp \
  --mount type=bind,source=$HOST_PROFILINGS_DIR,target=/workspace/profilings \
   tiagonapoli/dotnet5.0-profiling-sidecar:kernel-$KERNEL_VERSION "$ENTRYPOINT"
