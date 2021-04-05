FROM tiagonapoli/linux-kernel-src as build

ARG LINUX_KERNEL_VERSION

RUN git checkout $LINUX_KERNEL_VERSION && \
    cd tools/perf && ls -l && make O=/tmp/ && ls /tmp/

RUN rm -rf /src

FROM mcr.microsoft.com/dotnet/sdk:5.0-focal

RUN apt-get update && apt-get install -y \
  strace binutils-dev libaudit-dev libbabeltrace-ctf-dev libcap-dev libcap2 libdw-dev libelf-dev libiberty-dev libnuma-dev libpci3 libslang2-dev libssl-dev libunwind-dev libzstd-dev linux-tools-common python-dev systemtap-sdt-dev \
  && rm -rf /var/lib/apt/lists/*

# Install dotnet tools
RUN dotnet tool install --tool-path /tools dotnet-trace && ln -s /tools/dotnet-trace /bin/dotnet-trace
RUN dotnet tool install --tool-path /tools dotnet-dump && ln -s /tools/dotnet-dump /bin/dotnet-dump
RUN dotnet tool install --tool-path /tools dotnet-gcdump && ln -s /tools/dotnet-dump /bin/dotnet-gcdump
RUN dotnet tool install --tool-path /tools dotnet-counters && ln -s /tools/dotnet-counters /bin/dotnet-counters
RUN dotnet tool install --tool-path /tools dotnet-symbol && ln -s /tools/dotnet-symbol /bin/dotnet-symbol

COPY --from=build /tmp/ /perf/
RUN rm /bin/perf && ln -s /perf/perf /bin/perf

WORKDIR /workspace
RUN mkdir profilings

COPY ./scripts/ ./scripts
RUN cp ./scripts/profcpu.sh /bin/profcpu

COPY ./utils/flamegraph-utils ./flamegraph-utils
COPY ./utils/perf.config /root/.perfconfig

ENTRYPOINT [ "/bin/bash", "-l", "-c" ]
CMD [ "/bin/bash" ]