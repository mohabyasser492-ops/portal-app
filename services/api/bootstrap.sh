#!/usr/bin/env bash
set -e
dotnet new sln -n PortalApp
dotnet sln add src/*/*.csproj tests/*/*.csproj
