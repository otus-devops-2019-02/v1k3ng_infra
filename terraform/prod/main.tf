terraform {
  # Версия terraform
  #	required_version = "0.11.11"
  required_version = ">=0.11,<0.12"
}

provider "google" {
  # Версия провайдера
  version = "2.0.0"

  # ID проекта
  project = "${var.project}"
  region  = "${var.region}"
}

resource "google_compute_project_metadata" "default" {
  project = "${var.project}"

  metadata {
    ssh-keys = "appuser:${file(var.public_key_path)}"
  }
}

module "app" {
  source           = "../modules/app"
  public_key_path  = "${var.public_key_path}"
  private_key_path = "${var.private_key_path}"
  zone             = "${var.zone}"
  app_disk_image   = "${var.app_disk_image}"
  machine_type     = "${var.machine_type}"
  db_internal_ip   = "${module.db.db_internal_ip}"
  need_deploy      = "${var.need_deploy}"
}

module "db" {
  source           = "../modules/db"
  public_key_path  = "${var.public_key_path}"
  private_key_path = "${var.private_key_path}"
  zone             = "${var.zone}"
  db_disk_image    = "${var.db_disk_image}"
  machine_type     = "${var.machine_type}"
  app_internal_ip  = "${module.app.app_internal_ip}"
}

module "vpc" {
  source        = "../modules/vpc"
  source_ranges = ["178.236.210.50/32"]
}
