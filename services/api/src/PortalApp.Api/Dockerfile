FROM mcr.microsoft.com/dotnet/sdk:8.0 AS restore

WORKDIR /source

COPY Directory.Build.props ./
COPY PortalApp.sln ./

COPY src/PortalApp.Api/PortalApp.Api.csproj src/PortalApp.Api/
COPY src/PortalApp.Application/PortalApp.Application.csproj src/PortalApp.Application/
COPY src/PortalApp.Domain/PortalApp.Domain.csproj src/PortalApp.Domain/
COPY src/PortalApp.Infrastructure/PortalApp.Infrastructure.csproj src/PortalApp.Infrastructure/

RUN dotnet restore src/PortalApp.Api/PortalApp.Api.csproj

FROM restore AS build

COPY . .

RUN dotnet publish src/PortalApp.Api/PortalApp.Api.csproj \
    --configuration Release \
    --no-restore \
    --output /app/publish \
    /p:UseAppHost=false

FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS runtime

WORKDIR /app

RUN addgroup --system --gid 10001 portalapp \
    && adduser --system --uid 10001 --ingroup portalapp portalapp

COPY --from=build --chown=portalapp:portalapp /app/publish .

USER portalapp

ENV ASPNETCORE_URLS=http://+:8080
ENV ASPNETCORE_ENVIRONMENT=Production
ENV DOTNET_RUNNING_IN_CONTAINER=true

EXPOSE 8080

ENTRYPOINT ["dotnet", "PortalApp.Api.dll"]