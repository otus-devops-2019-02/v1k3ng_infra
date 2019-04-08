// resource "google_compute_backend_service" "website" {
//   name        = "my-backend"
//   description = "reddit-apps"
//   port_name   = "http"
//   protocol    = "HTTP"
//   timeout_sec = 10
//   enable_cdn  = false
//   backend {
//     group = "${google_compute_instance_group_manager.webservers.instance_group}"
//   }
//   health_checks = ["${google_compute_http_health_check.default.self_link}"]
// }
// resource "google_compute_instance_group_manager" "webservers" {
//   name = "my-webservers"
//   instance_template  = "${google_compute_instance_template.webserver.self_link}"
//   base_instance_name = "webserver"
//   zone               = "${var.zone}"
//   target_size        = 1
// }
// resource "google_compute_instance_template" "webserver" {
//   name         = "reddit-webserver"
//   machine_type = "g1-small"
//   network_interface {
//     network = "default"
//   }
//   disk {
//     source_image = "reddit-base"
//     auto_delete  = true
//     boot         = true
//   }
// }

resource "google_compute_target_pool" "default" {
  name = "reddit-pool"

  instances = [
    "${var.zone}/reddit-app",
  ]

  health_checks = [
    "${google_compute_http_health_check.default.name}",
  ]
}

resource "google_compute_http_health_check" "default" {
  name               = "test"
  port               = "9292"
  request_path       = "/"
  check_interval_sec = 1
  timeout_sec        = 1
}

// resource "google_compute_firewall" "default" {
//   name    = "reddit-lb-rule"
//   network = "default"
//   allow {
//     protocol = "tcp"
//     ports    = ["9292"]
//   }
//   source_ranges = ["0.0.0.0/0"]
//   target_tags   = ["reddit-app"]
// }

resource "google_compute_forwarding_rule" "default" {
  name       = "reddit-lb-rule"
  target     = "${google_compute_target_pool.default.self_link}"
  port_range = "9292"
}
