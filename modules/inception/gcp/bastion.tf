locals {
  tag           = "${local.name_prefix}-bastion"
  cfssl_version = "1.4.1"
}

resource "google_service_account" "bastion" {
  project      = local.project
  account_id   = "${local.name_prefix}-bastion"
  display_name = "Bastion account for ${local.name_prefix}"
}

resource "google_compute_address" "bastion" {
  project = local.project
  name    = "${local.name_prefix}-bastion"
  region  = local.region
}

resource "google_compute_instance" "bastion" {
  project      = local.project
  name         = "${local.name_prefix}-bastion"
  machine_type = local.bastion_machine_type
  zone         = local.cluster_zone

  service_account {
    email  = google_service_account.bastion.email
    scopes = ["https://www.googleapis.com/auth/cloud-platform"]
  }

  tags = [local.tag]

  boot_disk {
    initialize_params {
      image = local.bastion_image
    }
  }

  network_interface {
    subnetwork = google_compute_subnetwork.dmz.self_link

    access_config {
      nat_ip = google_compute_address.bastion.address
    }
  }

  metadata = {
    enable-oslogin = "TRUE"
  }

  metadata_startup_script = templatefile("${path.module}/bastion-startup.tmpl", {
    cluster_name : "${local.name_prefix}-cluster",
    zone : local.cluster_zone,
  project : local.project, cfssl_version : local.cfssl_version })
}

data "google_iam_policy" "bastion" {
  binding {
    role    = "roles/compute.osLogin"
    members = local.platform_admins
  }
  binding {
    role    = "roles/compute.viewer"
    members = local.platform_admins
  }
  binding {
    role    = "roles/compute.admin"
    members = ["serviceAccount:${var.inception_sa}"]
  }
}

resource "google_compute_instance_iam_policy" "bastion" {
  project       = local.project
  zone          = google_compute_instance.bastion.zone
  instance_name = google_compute_instance.bastion.name
  policy_data   = data.google_iam_policy.bastion.policy_data
}

resource "google_compute_firewall" "bastion_allow_all_inbound" {
  project = local.project
  name    = "${local.name_prefix}-bastion-allow-ingress"

  network = google_compute_network.vpc.self_link

  target_tags   = [local.tag]
  direction     = "INGRESS"
  source_ranges = ["0.0.0.0/0"]

  priority = "1000"

  allow {
    protocol = "all"
  }
}
