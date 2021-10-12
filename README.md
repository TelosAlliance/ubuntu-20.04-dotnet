# Ubuntu 20.04 LTS build container + dotnet

This container is based on the Telos Alliance Ubuntu 20.04 build container but with additional support for building dotnet core applications.

## Tools

- See https://hub.docker.com/r/telosalliance/ubuntu-20.04
- dotnet core sdk (note: Each tag might have different versions of the dotnet core sdk)
- extlinux
- libguestfs-tools

## Prerequisites

Make sure you have `docker` installed, and you are part of the `docker` group. Running as root is not recommended.

## Usage

See https://hub.docker.com/r/telosalliance/ubuntu-20.04

This image extends the image above with additional tools for dotnet core compilation and a few other specifics needed by projects building images/applications that use dotnet core.

