# Hyrax

# Create the Build Script
# Set do_build to 'true' to build new images - this will take c. 30 mins
#   @todo build needs to delay hyrax and sidekiq pod creation, hence it being false
data "template_file" "build_script" {
  template = "${file("${path.cwd}/docker_build.tpl")}"
  vars = {
    do_build = false
    # we can use the same image for both web and worker
    # images = "hyrax_leaf_workers,hyrax_leaf_web"
    images = "hyrax_leaf_web"
  }
}

resource "local_file" "build" {
  content = "${data.template_file.build_script.rendered}"
  filename = "docker_build.rb"
  # Build (if do_build is set to true), tag and push the docker images
  # @todo ensure this completes before the containers pushed / deployed
  provisioner "local-exec" "build" {
    command = "ruby docker_build.rb"
  }
  
  provisioner "local-exec" "build" {
    command = "docker tag hyrax_leaf_web ${module.azure_kubernetes.azure_container_registry_name}.azurecr.io/hyrax/hyrax_leaf_web"
    }
  
#  provisioner "local-exec" "build" {
#    command = "docker tag hyrax_leaf_workers ${module.azure_kubernetes.azure_container_registry_name}.azurecr.io/hyrax/hyrax_leaf_workers"
#    }
  
  provisioner "local-exec" "build" {
    command = "az acr login --name ${module.azure_kubernetes.azure_container_registry_name}"
    }
  
  provisioner "local-exec" "build" {
    command = "docker push ${module.azure_kubernetes.azure_container_registry_name}.azurecr.io/hyrax/hyrax_leaf_web"
    }
  
#  provisioner "local-exec" "build" {
#    command = "docker push ${module.azure_kubernetes.azure_container_registry_name}.azurecr.io/hyrax/hyrax_leaf_workers"
#  }
}

module "kubernetes_hyrax" {
  source = "git::https://github.com/anarchist-raccoons/terraform_kubernetes_deployment.git?ref=master"

  host = "${module.azure_kubernetes.host}"
  username = "${module.azure_kubernetes.username}"
  password = "${module.azure_kubernetes.password}"
  client_certificate = "${module.azure_kubernetes.client_certificate}"
  client_key = "${module.azure_kubernetes.client_key}"
  cluster_ca_certificate = "${module.azure_kubernetes.cluster_ca_certificate}"

  docker_image = "${module.azure_kubernetes.azure_container_registry_name}.azurecr.io/hyrax/hyrax_leaf_web:latest"
  app_name = "hyrax"
  primary_mount_path = "/data"
  secondary_mount_path = "/app/shared/state"
  secondary_sub_path = "state"
  pvc_claim_name = "${module.kubernetes_pvc_hyrax.pvc_claim_name}"
  port = 3000
  image_pull_secrets = "${module.kubernetes_secret_docker.kubernetes_secret_name}"
  env_from = "${module.kubernetes_secret_env.kubernetes_secret_name}"
  command = ["/bin/bash","-ce", "/bin/docker-entrypoint-web.sh"]
  # Creates a dependency on fcrepo, solr and redis
  resource_version = ["${module.kubernetes_fcrepo.service_resource_version}","${module.kubernetes_fcrepo.deployment_resource_version}","${module.kubernetes_solr.deployment_resource_version}","${module.kubernetes_solr.service_resource_version}",  "${module.kubernetes_redis.deployment_resource_version}","${module.kubernetes_redis.service_resource_version}"]

}

# Sidekiq

module "kubernetes_sidekiq" {
  source = "git::https://github.com/anarchist-raccoons/terraform_kubernetes_deployment.git?ref=master"

  host = "${module.azure_kubernetes.host}"
  username = "${module.azure_kubernetes.username}"
  password = "${module.azure_kubernetes.password}"
  client_certificate = "${module.azure_kubernetes.client_certificate}"
  client_key = "${module.azure_kubernetes.client_key}"
  cluster_ca_certificate = "${module.azure_kubernetes.cluster_ca_certificate}"

  docker_image = "${module.azure_kubernetes.azure_container_registry_name}.azurecr.io/hyrax/hyrax_leaf_web:latest"
  app_name = "sidekiq"
  primary_mount_path = "/data"
  secondary_mount_path = "/app/shared/state"
  secondary_sub_path = "state"
  pvc_claim_name = "${module.kubernetes_pvc_hyrax.pvc_claim_name}"
  port = 3001
  image_pull_secrets = "${module.kubernetes_secret_docker.kubernetes_secret_name}"
  env_from = "${module.kubernetes_secret_env.kubernetes_secret_name}"
  command = ["/bin/bash","-ce", "/bin/docker-entrypoint-worker.sh"]
  # Creates a dependency on fcrepo, solr and redis
  resource_version = ["${module.kubernetes_fcrepo.service_resource_version}","${module.kubernetes_fcrepo.deployment_resource_version}","${module.kubernetes_solr.deployment_resource_version}","${module.kubernetes_solr.service_resource_version}",  "${module.kubernetes_redis.deployment_resource_version}","${module.kubernetes_redis.service_resource_version}"]
}

module "kubernetes_pvc_hyrax" {
  source = "git::https://github.com/anarchist-raccoons/terraform_kubernetes_pvc.git?ref=master"

  host = "${module.azure_kubernetes.host}"
  username = "${module.azure_kubernetes.username}"
  password = "${module.azure_kubernetes.password}"
  client_certificate = "${module.azure_kubernetes.client_certificate}"
  client_key = "${module.azure_kubernetes.client_key}"
  cluster_ca_certificate = "${module.azure_kubernetes.cluster_ca_certificate}"
  
  volume = "hyraxsidekiq"

}