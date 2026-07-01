output "containers" {
  value = {
    web = {
      for name, instance in module.web :
      name => instance.container
    }

    app = module.app.container
    postgres = {
      id           = docker_container.postgres.id
      name         = docker_container.postgres.name
      image        = docker_container.postgres.image
      network_data = docker_container.postgres.network_data
      ports        = docker_container.postgres.ports
    }
  }
}
