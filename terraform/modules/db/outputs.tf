// output "app_external_ip" {
//   value = "${google_compute_instance.app0.network_interface.0.access_config.0.nat_ip}"
// }

output "db_external_ip" {
  value = "${google_compute_instance.db.network_interface.0.access_config.0.nat_ip}"
}

output "db_internal_ip" {
  value = "${google_compute_instance.db.network_interface.0.network_ip}"
}

// output "target_pool_ip" {
//   value = "${google_compute_forwarding_rule.default.ip_address}"
// }

