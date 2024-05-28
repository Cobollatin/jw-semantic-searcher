# Use the .NET SDK to build the application
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src

# Copy the project files
COPY indexer/*.csproj ./indexer/
RUN dotnet restore "./indexer/indexer.csproj"

# Copy the rest of the application
COPY indexer/. ./indexer/
WORKDIR /src/indexer
RUN dotnet publish -c Release -o /app/publish

# Use the .NET runtime image to run the application
FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS runtime
WORKDIR /app
COPY --from=build /app/publish .
ENTRYPOINT ["dotnet", "indexer.dll"]
