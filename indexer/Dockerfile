# Use the .NET SDK image for building the application
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build-env
USER root
# Copy the entire solution and restore dependencies
WORKDIR /app
COPY . /app
RUN dotnet restore

# Publish the application
RUN dotnet publish -c Release -o out

# Use the .NET runtime image to run the application
FROM mcr.microsoft.com/dotnet/runtime:8.0
USER root

# Copy the published output from the build stage into the runtime image
COPY --from=build-env /app/out .

# Specify the entry point for the application
ENTRYPOINT ["dotnet", "indexer.dll"]
