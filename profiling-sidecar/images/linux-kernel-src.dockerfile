FROM mcr.microsoft.com/dotnet/sdk:5.0-focal

RUN mkdir /src
WORKDIR /src

RUN git clone git://git.kernel.org/pub/scm/linux/kernel/git/stable/linux-stable.git
WORKDIR /src/linux-stable/
RUN ls /src/linux-stable/

RUN apt-get update && apt-get install -y \
  binutils-dev bison curl elfutils flex gcc git libaudit-dev libbabeltrace-ctf-dev libcap-dev libcap2 libdw-dev libelf-dev libiberty-dev libnuma-dev libpci3 libperl-dev libslang2-dev libssl-dev libunwind-dev libzstd-dev linux-tools-common make python-dev systemtap-sdt-dev xz-utils \
  && rm -rf /var/lib/apt/lists/*












