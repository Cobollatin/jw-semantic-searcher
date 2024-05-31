# Use the .NET SDK image for building the application
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build-env
USER root
RUN mkdir /app
WORKDIR /app
COPY . /app
RUN dotnet restore
RUN dotnet publish -c Release -o out

FROM mcr.microsoft.com/dotnet/runtime:8.0
USER root
RUN mkdir /indexer
WORKDIR /indexer
COPY "docker-entrypoint.sh" /indexer
ADD data /indexer/data
RUN chmod +x /indexer/docker-entrypoint.sh
COPY --from=build-env /app/out /indexer
ENTRYPOINT ["/indexer/docker-entrypoint.sh"]
CMD ["dotnet", "indexer.dll"]
