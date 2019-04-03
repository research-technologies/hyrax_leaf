# Redis
module "kubernetes_redis" {
  source = "git::https://github.com/anarchist-raccoons/terraform_kubernetes_deployment.git?ref=master"

  host = "${module.azure_kubernetes.host}"
  username = "${module.azure_kubernetes.username}"
  password = "${module.azure_kubernetes.password}"
  client_certificate = "${module.azure_kubernetes.client_certificate}"
  client_key = "${module.azure_kubernetes.client_key}"
  cluster_ca_certificate = "${module.azure_kubernetes.cluster_ca_certificate}"

  docker_image = "redis:5"
  app_name = "redis"
  primary_mount_path = "/data"
  secondary_mount_path = "/redis"
  secondary_sub_path = ""
  pvc_claim_name = "${module.kubernetes_pvc_redis.pvc_claim_name}"

  port = 6379
  env_from = "${module.kubernetes_secret_env.kubernetes_secret_name}"
  image_pull_secrets = "${module.kubernetes_secret_docker.kubernetes_secret_name}"
}

module "kubernetes_pvc_redis" {
  source = "git::https://github.com/anarchist-raccoons/terraform_kubernetes_pvc.git?ref=master"

  host = "${module.azure_kubernetes.host}"
  username = "${module.azure_kubernetes.username}"
  password = "${module.azure_kubernetes.password}"
  client_certificate = "${module.azure_kubernetes.client_certificate}"
  client_key = "${module.azure_kubernetes.client_key}"
  cluster_ca_certificate = "${module.azure_kubernetes.cluster_ca_certificate}"
  
  volume = "redis"

}

