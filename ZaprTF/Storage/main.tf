resource "google_storage_bucket" "image-store" {
  name     = "spinnaker-gcs-bucket-${var.project}"
  location = "${var.storage_region}"
  storage_class = "${var.storage_class}"
}
