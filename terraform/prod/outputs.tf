// output "app_external_ip" {
//   value = "${google_compute_instance.app0.network_interface.0.access_config.0.nat_ip}"
// }
// output "apps_external_ip" {
//   value = "${google_compute_instance.app.*.network_interface.0.access_config.0.nat_ip}"
// }
// output "target_pool_ip" {
//   value = "${google_compute_forwarding_rule.default.ip_address}"
// }

output "app_external_ip" {
  value       = "http://${module.app.app_external_ip}:9292"
  description = "The URI of the created resource."
}
