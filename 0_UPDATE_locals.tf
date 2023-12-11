locals {
  #-----------------------------------------------------------------------------------------------------
  # General variables
  #-----------------------------------------------------------------------------------------------------
  prefix = "plf-eng"

  tags = {
    Deploy  = "demo platform-engineering"
    Project = "platform-engineering"
  }

  #-----------------------------------------------------------------------------------------------------
  # FGT Clusters
  #-----------------------------------------------------------------------------------------------------
  fgt_admin_port = "8443"
  fgt_admin_cidr = "0.0.0.0/0"

  fgt_license_type = "byol"
  fortiflex_token  = var.fortiflex_token

  fgt_build         = "build1575" // version 7.2.6
  fgt_instance_type = "c6i.large"

  #--------------------------------------------------------------------------------------------------
  # APPs details
  #--------------------------------------------------------------------------------------------------
  app = "plf-eng"
  # AWS Route53 zone
  route53_zone_name = "fortidemoscloud.com"
  # DNS names
  app_1_dns_name = "${local.app}-votes"   // special character "-" (not allowed "_" or ".")
  app_2_dns_name = "${local.app}-results" // special character "-" (not allowed "_" or ".")
  # variables used in deployment manifest
  app_1_nodeport = "31000"
  app_2_nodeport = "31001"

  #--------------------------------------------------------------------------------------------------
  # Github repo variables
  #--------------------------------------------------------------------------------------------------
  github_site          = "fortidemoscloud"
  github_repo_name_app = "${local.app}-catdogs"

  git_author_email = "fortidemoscloud@proton.me"
  git_author_name  = "fortidemoscloud"

  # Create secrets values to deploy APP in k8s cluster
  fgt_values = {
    HOST        = "${module.aws_fgt.fgt_eip_public}:${local.fgt_admin_port}"
    PUBLIC_IP   = module.aws_fgt.fgt_eip_public
    EXTERNAL_IP = module.aws_fgt_vpc.fgt_ni_ips["public"]
    MAPPED_IP   = module.aws_node_master.vm["private_ip"]
    TOKEN       = trimspace(random_string.api_key.result)
  }
  # CLI command to get necessary values from k8s cluster
  k8s_values_cli = {
    KUBE_TOKEN       = "redis-cli -h ${local.db_host_public_ip} -p ${local.db_port} -a ${local.db_pass} --no-auth-warning GET ${local.db_prefix}_cicd-access_token"
    KUBE_HOST        = "echo ${local.master_public_ip}:${local.api_port}"
    KUBE_CERTIFICATE = "redis-cli -h ${local.db_host_public_ip} -p ${local.db_port} -a ${local.db_pass} --no-auth-warning GET ${local.db_prefix}_master_ca_cert"
  }
  # TOKEN and CERTIFICATE will need to be updated after deploy this terraform
  k8s_values = {
    KUBE_TOKEN       = "get-token-after-deploy"
    KUBE_HOST        = "${local.master_public_ip}:${local.api_port}"
    KUBE_CERTIFICATE = "get-cert-after-deploy"
  }
  #-----------------------------------------------------------------------------------------------------
  # FortiWEB Cloud
  #-----------------------------------------------------------------------------------------------------
  # Fortiweb Cloud template ID
  fwb_cloud_template = "4f649540-cb52-4ef7-85e7-be12dafe1f29"
  # FortiWEB Cloud regions where deploy
  fortiweb_region = var.region["id"]
  # FortiWEB Cloud platform names
  fortiweb_platform = "AWS"

  #-----------------------------------------------------------------------------------------------------
  # K8S Clusters variables
  #-----------------------------------------------------------------------------------------------------
  worker_number        = 1
  k8s_version          = "1.24.10-00"
  node_master_cidrhost = 10 //Network IP address for master node
  disk_size            = 30

  linux_user         = "ubuntu"
  node_instance_type = "t3.2xlarge"
  master_public_ip   = module.aws_fgt.fgt_eip_public
  db_host_public_ip  = module.aws_fgt.fgt_eip_public
  master_ip          = cidrhost(local.aws_nodes_subnet_cidr, local.node_master_cidrhost)
  db_host            = cidrhost(local.aws_nodes_subnet_cidr, local.node_master_cidrhost)
  db_port            = 6379
  db_pass            = trimspace(random_string.api_key.result)
  db_prefix          = "aws"

  api_port = 6443

  #-----------------------------------------------------------------------------------------------------
  # AWS FGT ONRAMP
  #-----------------------------------------------------------------------------------------------------
  aws_spoke_cidr = "172.20.0.0/24"
  aws_spoke = {
    id      = "spoke"
    cidr    = local.aws_spoke_cidr
    bgp_asn = "65000"
  }

  aws_nodes_subnet_id   = module.aws_fgt_vpc.subnet_az1_ids["bastion"]
  aws_nodes_subnet_cidr = module.aws_fgt_vpc.subnet_az1_cidrs["bastion"]
  aws_nodes_sg_id       = module.aws_fgt_vpc.nsg_ids["allow_all"]
}