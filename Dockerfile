FROM telosalliance/ubuntu-18.04

ENV DOTNET_SDK_VERSION 2.1.805
RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 291F9FF6FD385783 \
   && apt-get update \
   && apt-get install -y --no-install-recommends \
     libguestfs-tools \
     extlinux \
     libelf-dev \
     libc6 \
     libgcc1 \
     libgssapi-krb5-2 \
     libicu60 \
     liblttng-ust0 \
     libssl1.0.0 \
     libstdc++6 \
     zlib1g \
     uuid-runtime \
     nano \
   && curl -SL --output dotnet.tar.gz https://dotnetcli.azureedge.net/dotnet/Sdk/$DOTNET_SDK_VERSION/dotnet-sdk-$DOTNET_SDK_VERSION-linux-x64.tar.gz \
   && dotnet_sha512='ceceaf569060c313e9e1b519ad2bfda37bb11c4549689d01080bed84b8a1b64f4c8a35fce4622b2f951a7ccf574e7ea4552c076fa2ba302846d4e1c5ae5b3a0c' \
   && echo "$dotnet_sha512 dotnet.tar.gz" | sha512sum -c - \
   && mkdir -p /usr/share/dotnet \
   && tar -zxf dotnet.tar.gz -C /usr/share/dotnet \
   && rm dotnet.tar.gz \
   && ln -s /usr/share/dotnet/dotnet /usr/bin/dotnet \
   && apt-get clean \
   && rm -rf /var/lib/apt/lists/*

ENV DOTNET_RUNNING_IN_CONTAINER=true \
    DOTNET_USE_POLLING_FILE_WATCHER=true \
    NUGET_XMLDOC_MODE=skip \
    DOTNET_SKIP_FIRST_TIME_EXPERIENCE=true
