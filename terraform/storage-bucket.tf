provider "google" {
  version = "2.0.0"
  project = "${var.project}"
  region  = "${var.region}"
}

// module "storage-bucket" {
//   source  = "SweetOps/storage-bucket/google"
//   version = "0.1.1"

//   # Имена поменяйте на другие
//   name = ["storage-bucket-for-state-v1k3ng"]
// }

output storage-bucket_url {
  value = "${google_storage_bucket.default.url}"
}

resource "google_storage_bucket" "default" {
  name = "storage-bucket-for-state-v1k3ng"
  force_destroy = "true"
  versioning {
    enabled = "true"
  }
}
