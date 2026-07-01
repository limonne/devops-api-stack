variable "name" {
  description = "Name for web"
  type        = string

  validation {
    condition     = length(var.name) > 0
    error_message = "Web Container name cannot be empty"
  }

}

variable "backend_network" {
  description = "Network name for docker network"
  type        = string

  validation {
    condition     = length(var.backend_network) > 0
    error_message = "Network name cannot be empty"
  }

}

variable "ports" {
  description = "Ports used for internal and external"
  type        = map(number)

  default = {
    internal = 80,
    external = 8080
  }

  validation {
    condition     = var.ports.internal > 0 && var.ports.external > 0
    error_message = "Internal and External port must be greater than zero"
  }

}

variable "image_id" {
  description = "Docker image ID"
  type        = string

  validation {
    condition     = length(var.image_id) > 0
    error_message = "Image ID cannot be empty"
  }

}
