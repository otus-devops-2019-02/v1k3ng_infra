terraform {
    backend "gcs" {
        bucket = "storage-bucket-for-state-v1k3ng"
        prefix = "stage"
    }
}
