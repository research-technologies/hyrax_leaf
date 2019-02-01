# hyrax_leaf
HyraxLeaf is the base Hyrax application used by the Research Technologies team

## Environment Variables
 * The environment variables are in two files .env and .env.production
 * Copy the file .env.production.example to .env.production
These are used by docker when running the containers and by the rails application.
 
### Note
The environment variables used by docker during build are hidden within the docker files. Some examples are
  * Postgres username and password
  * RAILS_ENV (set to production)
  * Gem key (set to hull_culture)

Until these are resolved to be all read from a single file, if you change these values, they also need to be changed in the docker files

## Install from docker
Ensure you have docker and docker-compose. See [notes on installing docker](https://github.com/research-technologies/hull_synchronizer/wiki/Notes-on-installing-docker)

To build and run the system in your local environment,

Clone the repository and switch to the feature/docker_setup branch
```
git clone https://github.com/research-technologies/hyrax_leaf.git
git fetch
git checkout feature/dockerize
```

Issue the docker-compose `up` command:
```bash
$ docker-compose up --build
```
You should see the rails app at localhost:3000
