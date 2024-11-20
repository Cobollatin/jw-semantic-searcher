# Semantic Searcher

Semantic Searcher is a comprehensive solution designed to leverage advanced semantic search capabilities. This project is structured into several key components, including a web application, an indexer service, and infrastructure management using Terraform.

## Components

### Web Application

The web application is built using Angular, providing a lightweight and efficient frontend for interacting with the semantic search capabilities. For more details on how to set up and run the web application, refer to the [webapp README.md](webapp/README.md).

### Indexer

The indexer is a .NET Core application responsible for processing and indexing data to be used in semantic searches. It includes a Docker setup for easy deployment and scalability. For more information, see the [indexer README.md](indexer/README.md) (Note: You might need to create or update this README based on the project's specifics). There is a python script called transformed that transform the JSON format of the Bible to a format that the indexer can understand.

### Infrastructure

Infrastructure management is handled through Terraform, allowing for the provisioning of required cloud resources in a consistent and reproducible manner. The setup includes configurations for Azure resources and OpenAI API integration. For detailed setup instructions, refer to the [infrastructure README.md](infrastructure/README.md).

## Getting Started

To get started with Semantic Searcher, clone this repository and follow the setup instructions for each component:

1. **Web Application**: Navigate to the `webapp` directory and follow the instructions in the README.
2. **Indexer**: Navigate to the `indexer` directory. Build and run the Docker container as described in the README.
3. **Infrastructure**: Navigate to the `infrastructure` directory. Follow the Terraform setup instructions in the README to provision the necessary cloud resources.

## Links

### Application

- [Semantic Searcher Web Application](https://zealous-mushroom-04e38f10f.5.azurestaticapps.net/)

### Sources

Bible source: <https://github.com/thiagobodruk/bible>

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
