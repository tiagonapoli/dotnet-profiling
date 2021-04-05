
set -euo pipefail

display_info() {
  printf "Usage ./download-net-symbols.sh [OPT]\nOptions are:\n"
  printf "  -c (ID): ID of the container in which symbols are to be downloaded\n"
  printf "  -a: Download symbols to all libraries on /dotnet/shared/Microsoft.NETCore.App\n"
  printf "  -h: Show this message\n"
  exit 0
}

CONTAINER_ID="$(sudo docker container ls -q)"
MODE="coreclr"
while getopts "c:ah" OPT; do
  case "$OPT" in
    "c") CONTAINER_ID=$OPTARG;;
    "a") MODE="all";;
    "h") display_info;;
    "?") display_info;;
  esac 
done


NETCORE_VERSION="$(sudo docker exec $CONTAINER_ID ls /usr/share/dotnet/shared/Microsoft.NETCore.App)"
COMMAND=""
if [ "$MODE" == "coreclr" ]; then
    COMMAND="/tools/dotnet-symbol --symbols --output /usr/lib/debug/usr/share/dotnet/shared/Microsoft.NETCore.App/$NETCORE_VERSION /usr/share/dotnet/shared/Microsoft.NETCore.App/$NETCORE_VERSION/libcoreclr.so"
else
    COMMAND="/tools/dotnet-symbol --symbols --output /usr/lib/debug/usr/share/dotnet/shared/Microsoft.NETCore.App/$NETCORE_VERSION /usr/share/dotnet/shared/Microsoft.NETCore.App/$NETCORE_VERSION/*"
fi

sudo docker exec -it $CONTAINER_ID $COMMAND