# Terraform

Please note, this terraform build should be considered experimental!

This is a terraform build to deploy hyrax_leaf leaf to an Azure Kubernetes Service.

## Prerequisites

* Terraform
* Docker and Docker compose
* Ruby
* Azure CLI
* Azure subscription
* gem install 'azure-storage-file'

## Variables and data

(relative to terraform/)

* create `terraform.tfvars` (see `terraform.tfvars.template`) OR (see convention below ../../terraform_builds/myapp/terraform.tfvars)
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

A suggested convention is to have a location outside of the GH repo for the tfvars, plan and state and set the locations at plan/apply time.

@todo remote state to share plans and state

```
# install modules (first time only); add --update to update modules
terraform init

# create
terraform plan -var-file=../../terraform_builds/test/test.tfvars -out=../../terraform_builds/test/test.tfplan -state=../../terraform_builds/test/terraform.tfstate
terraform apply -state-out=../../terraform_builds/test/terraform.tfstate ../../terraform_builds/test/test.tfplan" 

# destroy
terraform plan  -destroy -var-file=../../terraform_builds/test/test.tfvars -out=../../terraform_builds/test/test.tfplan -state=../../terraform_builds/test/terraform.tfstate
terraform apply -state-out=../../terraform_builds/test/terraform.tfstate ../../terraform_builds/test/test.tfplan"
```

## Automatic Stop|Start of the Kubernetes VM

The terraform plan creates and Automation Account and a Log Analytics Workspace. To enable automatic startup and shutdown of the underlying kubernetes VM, for example to save costs of a development or test machine, follow these steps:

In the Azure portal:

1. Navigate to Resource Group > Automation Account
2. In the left-hand menu, find Related Resources > Start/Stop VM
3. Select 'Learn more about and enable the solution' and hit Create
4. Choose the existing Automation Account, Log Analytics Workspace and Resource Group
5. In the configuration panel, enter the MC_ resource group, eg. MC_leaf-uat-rdg_leaf-uat-rdg_northeurope (this is important, otherwise the solution will shut down ALL VMs in your subscription)
6. Save

Once the deployment is complete, edit the schedules (Scheduled-StartVM and Scheduled-StopVM) as needed from within the automation account.