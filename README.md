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

## Embedding a Gem

HyraxLeaf can be used stand-alone, but has been designed for use with a Ruby Gem containing customisations that are applied by running the gem install generator. An example of one such gem is [hull_culture](https://github.com/research-technologies/hull_culture)

The convention for using a gem is:

1) clone the gem to `vendor/`
2) add the gem to the Gemfile: `gem_name, path: vendor/gem_name`
3) run the installer: `rails g gem_name:install`
4) optionally (if available), run the initialize generator on first run to run setup tasks like creating the default admin set: `rails g gem_name:initialize`

## Install from docker
Ensure you have docker and docker-compose. See [notes on installing docker](https://github.com/research-technologies/hull_synchronizer/wiki/Notes-on-installing-docker)

To build and run the system in your local environment.

1) Clone the repository
```bash
git clone https://github.com/research-technologies/hyrax_leaf.git
```

2) Copy .env-template to .evn and review the environment variables carefully

3) Issue the docker-compose `up` command (add --build to build the images):

```bash
$ docker-compose up --build
```

You should see the rails app at localhost:3000 (if you set EXTERNAL_PORT to a different port, it will be running on that port)

### Embedding a Gem

As noted above, a Gem may be used to customise hyrax_leaf. If the GEM_KEY and GEM_SOURCE variables are set, docker-compose will perform the steps noted earlier. 

If the GEM_SOURCE requires an ssh key, add the private key file to the docker folder and set SSH_PRIVATE_KEY to the path (eg. docker/id_rsa). Docker uses an intermediate image to ensure this key file is not included in the final docker image.

## Build an Azure Kubernetes Cluster with Terraform (experimental)

See the separate README in the `/terraform` directory