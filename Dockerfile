FROM telosalliance/ubuntu-20.04:2021-10-08

ENV \
    # Unset ASPNETCORE_URLS from aspnet base image
    ASPNETCORE_URLS= \
    # Do not generate certificate
    DOTNET_GENERATE_ASPNET_CERTIFICATE=false \
    # SDK version
    DOTNET_SDK_VERSION=5.0.401 \
    # Enable detection of running in a container
    DOTNET_RUNNING_IN_CONTAINER=true \
    # Enable correct mode for dotnet watch (only mode supported in a container)
    DOTNET_USE_POLLING_FILE_WATCHER=true \
    # Skip extraction of XML docs - generally not useful within an image/container - helps performance
    NUGET_XMLDOC_MODE=skip \
    # PowerShell telemetry for docker image usage
    POWERSHELL_DISTRIBUTION_CHANNEL=PSDocker-DotnetCoreSDK-Ubuntu-18.04

RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 291F9FF6FD385783 \
   && apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 684BA42D \
   && apt-get update \
   && apt-get install -y --no-install-recommends \
     libguestfs-tools \
     extlinux \
     fakeroot \
     libelf-dev \
     libc6 \
     libgcc1 \
     libgssapi-krb5-2 \
     libicu66 \
     liblttng-ust0 \
     libssl1.1 \
     libstdc++6 \
     zlib1g \
     uuid-runtime \
     nano \
     # required for ldap-python / openldap compiling \
     python3-dev \
     python2.7-dev \
     libldap2-dev \
     libsasl2-dev \
     ldap-utils \
     tox \
     lcov \
     python-six \
     python-setuptools \
     # above for ldap-python \
   && apt-get clean \
   && rm -rf /var/lib/apt/lists/*

# Install .NET Core SDK
RUN curl -SL --output dotnet.tar.gz https://dotnetcli.azureedge.net/dotnet/Sdk/$DOTNET_SDK_VERSION/dotnet-sdk-$DOTNET_SDK_VERSION-linux-x64.tar.gz \
    && dotnet_sha512='a444d44007709ceb68d8f72dec0531e17f85f800efc0007ace4fa66ba27f095066930e6c6defcd2f85cdedea2fec25e163f5da461c1c2b8563e5cd7cb47091e0' \
    && echo "$dotnet_sha512  dotnet.tar.gz" | sha512sum -c - \
    && mkdir -p /usr/share/dotnet \
    && tar -ozxf dotnet.tar.gz -C /usr/share/dotnet \
    && rm dotnet.tar.gz \
    && ln -s /usr/share/dotnet/dotnet /usr/bin/dotnet \
    # Trigger first run experience by running arbitrary cmd
    && dotnet help

# Install PowerShell global tool
RUN powershell_version=7.1.4 \
    && curl -SL --output PowerShell.Linux.x64.$powershell_version.nupkg https://pwshtool.blob.core.windows.net/tool/$powershell_version/PowerShell.Linux.x64.$powershell_version.nupkg \
    && powershell_sha512='b163608ef7ceb5bae84cc8e841ff3dc1a6df129737444084dfeaaa7911c86e0084f5418926541aed97be5886bc4a14c9777741d15192b87c263c0b86b8391e0e' \
    && echo "$powershell_sha512  PowerShell.Linux.x64.$powershell_version.nupkg" | sha512sum -c - \
    && mkdir -p /usr/share/powershell \
    && dotnet tool install --add-source / --tool-path /usr/share/powershell --version $powershell_version PowerShell.Linux.x64 \
    && dotnet nuget locals all --clear \
    && rm PowerShell.Linux.x64.$powershell_version.nupkg \
    && ln -s /usr/share/powershell/pwsh /usr/bin/pwsh \
    && chmod 755 /usr/share/powershell/pwsh \
    # To reduce image size, remove the copy nupkg that nuget keeps.
    && find /usr/share/powershell -print | grep -i '.*[.]nupkg$' | xargs rm

RUN npm install -g npm@7.24.1

