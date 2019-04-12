# Copy the solr data
data "template_file" "copy_script" {
  template = "${file("${path.cwd}/copy_solr_config.tpl")}"
  vars = {
    azure_resource_group_name = "MC_${module.azure_kubernetes.azure_resource_group_name}_${module.azure_kubernetes.azure_resource_group_name}_${var.location}"
    share_name = "kubernetes-dynamic-${module.kubernetes_pvc_solr.volume_name}"
  }
}

# Transfer the solr config
resource "local_file" "create_copy_script" {
  
  content = "${data.template_file.copy_script.rendered}"
  filename = "create_copy_script.rb"

  provisioner "local-exec" "copy" {
    command = "ruby create_copy_script.rb"
  }
}

# solr
module "kubernetes_solr" {
  source = "git::https://github.com/anarchist-raccoons/terraform_kubernetes_deployment.git?ref=master"

  host = "${module.azure_kubernetes.host}"
  username = "${module.azure_kubernetes.username}"
  password = "${module.azure_kubernetes.password}"
  client_certificate = "${module.azure_kubernetes.client_certificate}"
  client_key = "${module.azure_kubernetes.client_key}"
  cluster_ca_certificate = "${module.azure_kubernetes.cluster_ca_certificate}"

  docker_image = "solr:7-alpine"
  app_name = "solr"
  primary_mount_path = "/opt/solr/server/solr/mycores"
  secondary_mount_path = "/data"
  secondary_sub_path = "solr_config"
  pvc_claim_name = "${module.kubernetes_pvc_solr.pvc_claim_name}"
  
  port = 8983
  image_pull_secrets = "${module.kubernetes_secret_docker.kubernetes_secret_name}"
  env_from = "${module.kubernetes_secret_env.kubernetes_secret_name}"
  
  command = ["/bin/bash","-ce", "docker-entrypoint.sh && solr-precreate $${SOLR_CORE} /data"]

}


module "kubernetes_pvc_solr" {
  source = "git::https://github.com/anarchist-raccoons/terraform_kubernetes_pvc.git?ref=master"

  host = "${module.azure_kubernetes.host}"
  username = "${module.azure_kubernetes.username}"
  password = "${module.azure_kubernetes.password}"
  client_certificate = "${module.azure_kubernetes.client_certificate}"
  client_key = "${module.azure_kubernetes.client_key}"
  cluster_ca_certificate = "${module.azure_kubernetes.cluster_ca_certificate}"
  
  volume = "solr"

}