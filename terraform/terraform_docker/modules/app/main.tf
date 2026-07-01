terraform {
  required_providers {
    docker = {
      source = "kreuzwerker/docker"
    }
  }
}

resource "docker_image" "app_image" {
  name = "alpine:latest"
}

resource "docker_container" "app" {
  name  = var.name
  image = docker_image.app_image.image_id

  command = [
    "tail",
    "-f",
    "/dev/null"
  ]

  networks_advanced {
    name = var.backend_network
  }
}
