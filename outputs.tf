output "container_definition" {
  value = "${data.template_file.container_definition.rendered}"
}
