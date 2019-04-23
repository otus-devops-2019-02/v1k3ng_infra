resource "google_compute_instance" "app" {
  name         = "reddit-app"
  machine_type = "${var.machine_type}"
  zone         = "${var.zone}"

  # определение загрузочного диска
  boot_disk {
    initialize_params {
      image = "${var.app_disk_image}"
    }
  }

  # определение сетевого интерфейса
  network_interface {
    # сеть, к которой присоединить данный интерфейс
    network = "default"

    # использовать IP reddit-app-ip
    access_config = {
      nat_ip = "${google_compute_address.app_ip.address}"
    }
  }

  metadata {
    # путь до публичного ключа
    ssh-keys = "appuser:${file(var.public_key_path)}"
  }

  tags = ["reddit-app"]

  connection {
    type  = "ssh"
    user  = "appuser"
    agent = false

    # путь до приватного ключа
    private_key = "${file(var.private_key_path)}"
  }

  // provisioner "file" {
  //   source      = "${path.module}/files/puma.service"
  //   destination = "/tmp/puma.service"
  // }

  // provisioner "remote-exec" {
  //   script = "${path.module}/files/deploy.sh"
  // }

  // provisioner "remote-exec" {
  //   inline = [
  //     "sudo sed -i 's/#Environment=DATABASE_URL=VALUE/Environment=DATABASE_URL=${var.db_internal_ip}/;' /etc/systemd/system/puma.service",
  //     "sudo systemctl daemon-reload",
  //     "sudo systemctl restart puma.service",
  //   ]
  // }
}

resource "null_resource" "app" {
  count = "${var.need_deploy == true ? 1 : 0}"

  connection {
    type  = "ssh"
    user  = "appuser"
    agent = false

    # путь до приватного ключа
    private_key = "${file(var.private_key_path)}"
    host = "${google_compute_instance.app.network_interface.0.access_config.0.nat_ip}" 
  }

  provisioner "file" {
    source      = "${path.module}/files/puma.service"
    destination = "/tmp/puma.service"
  }

  provisioner "remote-exec" {
    script = "${path.module}/files/deploy.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo sed -i 's/#Environment=DATABASE_URL=VALUE/Environment=DATABASE_URL=${var.db_internal_ip}/;' /etc/systemd/system/puma.service",
      "sudo systemctl daemon-reload",
      "sudo systemctl restart puma.service",
    ]
  }  
}

resource "google_compute_firewall" "firewall_puma" {
  name = "allow-puma-default"

  # Название сети, в которой действует правило
  network = "default"

  # Какой доступ разрешить
  allow {
    protocol = "tcp"
    ports    = ["9292", "80"]
  }

  # Каким адресам разрешаем доступ
  source_ranges = ["0.0.0.0/0"]

  # Правило применимо для инстансов с перечисленными тэгами
  target_tags = ["reddit-app"]
}

resource "google_compute_address" "app_ip" {
  name = "reddit-app-ip"
}
