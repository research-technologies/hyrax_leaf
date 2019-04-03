# hyrax_leaf
HyraxLeaf is the base Hyrax application used by the Research Technologies team

## Environment Variables

 * The environment variables used by docker when running the containers and by the rails application should be in file named .env
 * For docker, copy the file .env.template to .env and change / add the necessary information
 * For running the application without docker, setup the ENVIRONMENT VARIABLES as you would normally do so (eg. .rbenv-vars)

### Secrets

Generate a new secret with:

```
rails secret
```

## Install from docker
Ensure you have docker and docker-compose. See [notes on installing docker](https://github.com/research-technologies/hull_synchronizer/wiki/Notes-on-installing-docker)

To build and run the system in your local environment,

Clone the repository and switch to the feature/docker_setup branch
```
git clone https://github.com/research-technologies/hyrax_leaf.git
```

Issue the docker-compose `up` command:
```bash
$ docker-compose up --build
```

You should see the rails app at localhost:3000 (if you set EXTERNAL_PORT to a different port, it will be running on that port)

## Build an Azure Kubernetes Cluster with Terraform (experimental)

See the separate README in the `/terraform` directory