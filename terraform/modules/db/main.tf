resource "google_compute_instance" "db" {
  name         = "reddit-db"
  machine_type = "${var.machine_type}"
  zone         = "${var.zone}"

  # определение загрузочного диска
  boot_disk {
    initialize_params {
      image = "${var.db_disk_image}"
    }
  }

  # определение сетевого интерфейса
  network_interface {
    # сеть, к которой присоединить данный интерфейс
    network = "default"

    # использовать IP reddit-app-ip
    access_config = {
      //   nat_ip = "${google_compute_address.app_ip.address}"
    }
  }

  metadata {
    # путь до публичного ключа
    ssh-keys = "appuser:${file(var.public_key_path)}"
  }

  tags = ["reddit-db"]

  //   connection {
  //     type  = "ssh"
  //     user  = "appuser"
  //     agent = false

  //     # путь до приватного ключа
  //     private_key = "${file(var.private_key_path)}"
  //   }

  //   provisioner "file" {
  //     source      = "files/puma.service"
  //     destination = "/tmp/puma.service"
  //   }

  //   provisioner "remote-exec" {
  //     script = "files/deploy.sh"
  //   }
}

resource "google_compute_firewall" "firewall_mongo" {
  name    = "allow-mongo-default"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["27017"]
  }

  target_tags = ["reddit-db"]
  source_tags = ["reddit-app"]
}
