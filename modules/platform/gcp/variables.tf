variable "name_prefix" {}
variable "gcp_project" {}
variable "region" {
  default = "us-east1"
}
variable "primary_zone" {
  default = "b"
}
variable "network_prefix" {
  default = "10.1"
}
variable "kube_version" {
  default = "1.19.9-gke.1900"
}
variable "node_default_machine_type" {
  default = "e2-standard-2"
}
variable "node_service_account" {}
variable "min_default_node_count" {
  default = 1
}
variable "max_default_node_count" {
  default = 5
}

locals {
  name_prefix               = var.name_prefix
  cluster_name              = "${var.name_prefix}-cluster"
  master_ipv4_cidr_block    = "172.16.0.0/28"
  project                   = var.gcp_project
  region                    = var.region
  network_prefix            = var.network_prefix
  kube_version              = var.kube_version
  node_default_machine_type = var.node_default_machine_type
  nodes_service_account     = var.node_service_account
  min_default_node_count    = var.min_default_node_count
  max_default_node_count    = var.max_default_node_count
  cluster_zone              = "${local.region}-${var.primary_zone}"
}
