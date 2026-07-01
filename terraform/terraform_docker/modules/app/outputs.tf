output "container" {
  value = {
    id           = docker_container.app.id
    name         = docker_container.app.name
    image        = docker_container.app.image
    network_data = docker_container.app.network_data
    ports        = docker_container.app.ports
  }
}
