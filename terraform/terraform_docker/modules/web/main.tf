terraform {
  required_providers {
    docker = {
      source = "kreuzwerker/docker"
    }
  }
}

resource "docker_container" "web" {
  name  = var.name
  image = var.image_id

  ports {
    internal = var.ports.internal
    external = var.ports.external
  }

  lifecycle {
    ignore_changes = [
      ports
    ]
    #    create_before_destroy = true
  }

  networks_advanced {
    name = var.backend_network
  }
}
