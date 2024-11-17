FROM mcr.microsoft.com/dotnet/sdk:8.0 AS index-builder
USER root
RUN mkdir /indexer
WORKDIR /indexer
COPY . /indexer
RUN dotnet restore
RUN dotnet publish -c Release -o out

FROM mcr.microsoft.com/dotnet/runtime:8.0
USER root
RUN mkdir /indexer
WORKDIR /indexer
COPY "docker-entrypoint.sh" /indexer
ADD data /indexer/data
RUN chmod +x /indexer/docker-entrypoint.sh
COPY --from=index-builder /indexer/out /indexer
ENTRYPOINT ["/indexer/docker-entrypoint.sh"]
CMD ["sh","-c","dotnet /indexer/indexer.dll"]