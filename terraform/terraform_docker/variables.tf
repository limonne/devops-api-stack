variable "postgres_obj" {
  description = ""
  type        = string
}

variable "postgres" {
  description = "Postgres container configuration"

  type = object({
    name = string
    user = string
    pass = string
  })
}

variable "container" {
  description = "List of containers"
  type        = list(string)
}

variable "backend_network" {
  description = "Network name for docker network"
  type        = string
}

variable "db_data_name" {
  description = "Name for DB data volume in Docker"
  type        = string
  validation {
    condition     = length(var.db_data_name) > 0
    error_message = "DB data volume name cannot be empty"
  }
}

variable "ports" {
  description = "Ports used for internal and externar"

  type = map(number)

  default = {
    internal = 80
    external = 8080
  }

}

variable "nginx_multiple" {
  description = ""
  type        = map(any)
}
