FROM telosalliance/ubuntu-20.04:2021-10-08

ENV \
    # Unset ASPNETCORE_URLS from aspnet base image
    ASPNETCORE_URLS= \
    # Do not generate certificate
    DOTNET_GENERATE_ASPNET_CERTIFICATE=false \
    # SDK version
    DOTNET_SDK_VERSION=6.0.403 \
    # Enable detection of running in a container
    DOTNET_RUNNING_IN_CONTAINER=true \
    # Enable correct mode for dotnet watch (only mode supported in a container)
    DOTNET_USE_POLLING_FILE_WATCHER=true \
    # Skip extraction of XML docs - generally not useful within an image/container - helps performance
    NUGET_XMLDOC_MODE=skip \
    # PowerShell telemetry for docker image usage
    POWERSHELL_DISTRIBUTION_CHANNEL=PSDocker-DotnetCoreSDK-Ubuntu-20.04

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
RUN curl -fSL --output dotnet.tar.gz https://dotnetcli.azureedge.net/dotnet/Sdk/$DOTNET_SDK_VERSION/dotnet-sdk-$DOTNET_SDK_VERSION-linux-x64.tar.gz \
    && dotnet_sha512='779b3e24a889dbb517e5ff5359dab45dd3296160e4cb5592e6e41ea15cbf87279f08405febf07517aa02351f953b603e59648550a096eefcb0a20fdaf03fadde' \
    && echo "$dotnet_sha512  dotnet.tar.gz" | sha512sum -c - \
    && mkdir -p /usr/share/dotnet \
    && tar -ozxf dotnet.tar.gz -C /usr/share/dotnet \
    && rm dotnet.tar.gz \
    && ln -s /usr/share/dotnet/dotnet /usr/bin/dotnet \
    # Trigger first run experience by running arbitrary cmd
    && dotnet help

# Install PowerShell global tool
RUN powershell_version=7.2.7 \
    && curl -fSL --output PowerShell.Linux.x64.$powershell_version.nupkg https://pwshtool.blob.core.windows.net/tool/$powershell_version/PowerShell.Linux.x64.$powershell_version.nupkg \
    && powershell_sha512='465db0b02507d8c055a0ef9ae4e43395a9897b632660a0d1c07788159d13b9cc54d44823123ea001bbe3ad97740b0e5f998cb3378c84ba8824bc233559f32288' \
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

