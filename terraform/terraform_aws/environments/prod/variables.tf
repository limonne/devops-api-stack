variable "environment" {
  type = string
  validation {
    condition     = length(var.environment) > 0 && (var.environment == "prod" || var.environment == "test" || var.environment == "dev")
    error_message = "Must contain env, and must be prod, test or dev"
  }
  sensitive = true
}

variable "region" {
  type = string
}
