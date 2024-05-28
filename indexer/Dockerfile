# Use the .NET SDK image for building the application
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build-env
WORKDIR /App

# Copy the entire solution and restore dependencies
COPY . ./
RUN dotnet restore

# Publish the application
RUN dotnet publish -c Release -o out

# Use the .NET runtime image to run the application
FROM mcr.microsoft.com/dotnet/aspnet:8.0
WORKDIR /App

# Copy the published output from the build stage into the runtime image
COPY --from=build-env /App/out .

# Specify the entry point for the application
ENTRYPOINT ["dotnet", "DotNet.Docker.dll"]
