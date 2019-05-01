# fcrepo
module "kubernetes_fcrepo" {
  source = "git::https://github.com/anarchist-raccoons/terraform_kubernetes_deployment.git?ref=master"

  host = "${module.azure_kubernetes.host}"
  username = "${module.azure_kubernetes.username}"
  password = "${module.azure_kubernetes.password}"
  client_certificate = "${module.azure_kubernetes.client_certificate}"
  client_key = "${module.azure_kubernetes.client_key}"
  cluster_ca_certificate = "${module.azure_kubernetes.cluster_ca_certificate}"
  docker_image = "ualbertalib/docker-fcrepo4" # or nulib/fcrepo4"
  app_name = "fcrepo"
  primary_mount_path = "/data"
  secondary_mount_path = "/fcrepo" # currently unused, but could be
  secondary_sub_path = "fcrepo_config"
  pvc_claim_name = "${module.kubernetes_pvc_fcrepo.pvc_claim_name}"
  port = 8080
  image_pull_secrets = "${module.kubernetes_secret_docker.kubernetes_secret_name}"
  env_from = "${module.kubernetes_secret_env.kubernetes_secret_name}"
  load_balancer_source_ranges = "${var.developer_access}"

  # Creates a dependency on postgres
  resource_version = ["${module.kubernetes_postgres.service_resource_version}","${module.kubernetes_postgres.deployment_resource_version}"]
}

module "kubernetes_pvc_fcrepo" {
  source = "git::https://github.com/anarchist-raccoons/terraform_kubernetes_pvc.git?ref=master"

  host = "${module.azure_kubernetes.host}"
  username = "${module.azure_kubernetes.username}"
  password = "${module.azure_kubernetes.password}"
  client_certificate = "${module.azure_kubernetes.client_certificate}"
  client_key = "${module.azure_kubernetes.client_key}"
  cluster_ca_certificate = "${module.azure_kubernetes.cluster_ca_certificate}"
  
  volume = "fcrepo"

}