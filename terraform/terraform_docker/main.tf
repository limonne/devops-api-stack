terraform {
  required_providers {
    docker = {
      source = "kreuzwerker/docker"
    }
  }
}

provider "docker" {

}


## Locals section

locals {
  network_name = docker_network.backend_network.name
}

locals {
  default_ports = {
    internal = 80
    external = 8080
  }
}

locals {
  images = {
    nginx_image    = docker_image.nginx_image.image_id
    postgres_image = docker_image.postgres_image.image_id
  }
}

locals {
  workspace_name = terraform.workspace
}

## Dependencies section

resource "docker_image" "postgres_image" {
  name = "postgres:latest"
}

resource "docker_image" "nginx_image" {
  name = "nginx:latest"
}

# Create custom Network for Docker
resource "docker_network" "backend_network" {
  name = var.backend_network
  lifecycle {
    #    prevent_destroy = true
  }
}

# Create volume for postgres
resource "docker_volume" "postgres_data" {
  name = var.db_data_name
  lifecycle {
    #    prevent_destroy = true
  }
}

## Container creation section

# Create containers for nginx
module "web" {

  source          = "./modules/web"
  name            = "${each.key}-${local.workspace_name}"
  ports           = each.value
  backend_network = local.network_name
  image_id        = docker_image.nginx_image.image_id
  for_each        = var.nginx_multiple

}

# Create container for Postgres
resource "docker_container" "postgres" {
  name  = "${var.postgres.name}-container"
  image = local.images.postgres_image

  # Add container to backend_network
  networks_advanced {
    name = local.network_name
  }

  # Add Docker volume to Postgres
  volumes {
    volume_name    = docker_volume.postgres_data.name
    container_path = "/var/lib/postgresql"
  }

  # Define environment variables
  env = [
    "POSTGRES_USER=${var.postgres.user}",
    "POSTGRES_PASSWORD=${var.postgres.pass}",
    "POSTGRES_DB=${var.postgres.name}"
  ]

  ports {
    internal = 5432
  }
}

# Create container for app
module "app" {
  source          = "./modules/app"
  name            = "app"
  backend_network = local.network_name
}
