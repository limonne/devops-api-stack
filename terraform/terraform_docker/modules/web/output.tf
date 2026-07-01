output "container" {
  value = {
    id           = docker_container.web.id
    name         = docker_container.web.name
    image        = docker_container.web.image
    network_data = docker_container.web.network_data
    ports        = docker_container.web.ports
  }
}
