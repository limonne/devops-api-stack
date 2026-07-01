variable "name" {
  description = "Name for app"
  type        = string

  validation {
    condition     = length(var.name) > 0
    error_message = "App name cannot be empty"
  }

}

variable "backend_network" {
  description = "Network name for docker network"
  type        = string

  validation {
    condition     = length(var.backend_network) > 0
    error_message = "Backend Network name cannot be empty"
  }
}
