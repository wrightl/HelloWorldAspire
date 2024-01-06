FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS base
WORKDIR /app
EXPOSE 15287

ENV ASPNETCORE_URLS=http://+:15287

USER app
#FROM --platform=$BUILDPLATFORM mcr.microsoft.com/dotnet/sdk:8.0 AS build
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
ARG configuration=Release
WORKDIR /src
COPY ["HelloWorldAspire.ApiService/HelloWorldAspire.ApiService.csproj", "HelloWorldAspire.ApiService/"]
RUN dotnet restore "HelloWorldAspire.ApiService/HelloWorldAspire.ApiService.csproj"
COPY . .
WORKDIR "/src/HelloWorldAspire.ApiService"
RUN dotnet build "HelloWorldAspire.ApiService.csproj" -c $configuration -o /app/build

FROM build AS publish
ARG configuration=Release
RUN dotnet publish "HelloWorldAspire.ApiService.csproj" -c $configuration -o /app/publish /p:UseAppHost=false

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "HelloWorldAspire.ApiService.dll"]
