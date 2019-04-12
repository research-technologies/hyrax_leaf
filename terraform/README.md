# Terraform

Please note, this terraform build should be considered experimental

## Prerequisites

* Terraform
* Docker and Docker compose
* Azure CLI
* Azure subscription
* gem install 'azure-storage-file'

## Variables and data

(relative to terraform/)

* `terraform.tfvars` (see `terraform.tfvars.template`)
* create file `config.json` with {} as the contents - this will be overwritten with docker auth, but must not be committed to github
* Env file at `../.env` (see `../.env.template`)
* Solr config files at ../solr/config 

## Try it

You should have pre-built your docker images with (from the root dir where the compose and docker files are):

```
docker-compose build
```

then (from terraform):

```
terraform init
terraform plan
terraform apply
```

A suggested convention is to write the plan and state files to a location outside the repo, eg.

```
terraform init
terraform plan -out /some_dir/myapp.tfplan
terraform apply "/some_dir/myapp.tfplan" -state /some_dir/myapp.tfstate
```