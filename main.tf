data "template_file" "essential" {
  template = "$${jsonencode("essential")}: $${val ? true : false}"

  vars {
    val = "${var.essential != "" ? var.essential : "false"}"
  }
}

data "template_file" "command" {
  count    = "${length(var.command)}"
  template = "$${jsonencode(command_part)}"

  vars {
    command_part = "${element(var.command, count.index)}"
  }
}

data "template_file" "entry_point" {
  count    = "${length(var.entry_point)}"
  template = "$${jsonencode(entry_point_part)}"

  vars {
    entry_point_part = "${element(var.entry_point, count.index)}"
  }
}


data "template_file" "environment" {
  count = "${length(var.environment)}"

  template = "{\n     $${join(",\n     ",
  compact(
    list(
    "$${jsonencode("name")}: $${jsonencode(name)}",
    "$${jsonencode("value")}: $${jsonencode(value)}",
    )
  )
)}\n    }"

  vars {
    name  = "${lookup(var.environment[count.index], "name", "")}"
    value = "${lookup(var.environment[count.index], "value", "")}"
  }
}

data "template_file" "port_mappings" {
  count = "${length(var.port_mappings)}"

  template = <<JSON
{$${join(",\n",
  compact(
    list(
    host_port == "" ? "" : "$${jsonencode("hostPort") }: $${host_port}",
    "$${jsonencode("containerPort")}: $${container_port}",
    protocol == "" ? "" : "$${jsonencode("protocol")}: $${jsonencode(protocol)}"
    )
  )
)}}
JSON

  vars {
    host_port = "${lookup(var.port_mappings[count.index], "host_port", "")}"
    protocol  = "${lookup(var.port_mappings[count.index], "protocol", "tcp")}"

    # Use lookup here without defaults so that TF will raise an error on 
    # fields that are required.
    container_port = "${lookup(var.port_mappings[count.index], "container_port")}"
  }
}

data "template_file" "log_configuration" {
  template = <<JSON
"logConfiguration": {
    "logDriver": "awslogs",
    "options": {
      "awslogs-group": "$${logs_group}",
      "awslogs-region": "$${region}"
    }
  }
JSON

  vars {
    logs_group = "${var.logs_group}"
    region     = "${var.region}"
  }
}

data "template_file" "container_definition" {
  template = <<JSON
{
  $${val}
}
JSON

  vars {
    val = "${join(",\n  ",
      compact(list(
        "${jsonencode("name")}: ${jsonencode(var.name)}",
        "${length(var.command) > 0 ? "${jsonencode("command")}: [${join(", ", data.template_file.command.*.rendered)}]" : ""}",
        "${length(var.entry_point) > 0 ? "${jsonencode("entry_point")}: [${join(", ", data.template_file.entry_point.*.rendered)}]" : ""}",
        "${var.cpu != "" ? "${jsonencode("cpu")}: ${var.cpu}" : "" }",
        "${var.memory != "" ? "${jsonencode("memory")}: ${var.memory}" : "" }",
        "${var.logs_group != "" && var.region != "" ? "${trimspace(data.template_file.log_configuration.rendered)}" : "" }",
        "${jsonencode("image")}: ${jsonencode(var.image)}",
        "${length(var.links) > 0 ? "${jsonencode("links")}: ${jsonencode(var.links)}" : ""}",
        "${length(var.port_mappings) > 0 ? "${jsonencode("portMappings")}: [${join(",\n", data.template_file.port_mappings.*.rendered)}]" : ""}",
        "${length(var.environment) > 0 ? "${jsonencode("environment")}: [\n    ${join(",\n    ", data.template_file.environment.*.rendered)}\n  ]" : ""}",
        "${var.essential != "" ? data.template_file.essential.rendered : ""}"
      ))
    )}"
  }
}
