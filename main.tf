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

data "template_file" "environment" {
  count = "${length(var.environment)}"

  template = <<JSON
$${join(",\n",
  compact(
    list(
    "$${jsonencode("name")}: $${name}",
    "$${jsonencode("value")}: $${value}",
    )
  )
)}
JSON

  vars {
    name  = "${lookup(var.environment[count.index], "name", "")}"
    value = "${lookup(var.environment[count.index], "value", "")}"
  }
}

data "template_file" "port_mappings" {
  count = "${length(var.port_mappings)}"

  template = <<JSON
$${join(",\n",
  compact(
    list(
    hostPort == "" ? "" : "$${jsonencode("hostPort") }: $${host_port}",
    "$${jsonencode("containerPort")}: $${container_port}",
    protocol == "" ? "" : "$${jsonencode("protocol")}: $${jsonencode(protocol)}"
    )
  )
)}
JSON

  vars {
    host_port = "${lookup(var.port_mappings[count.index], "hostPort", "")}"

    # Use lookup here without defaults so that TF will raise an error on 
    # fields that are required.
    container_port = "${lookup(var.port_mappings[count.index], "containerPort")}"
    protocol       = "${lookup(var.port_mappings[count.index], "protocol", "")}"
  }
}

data "template_file" "log_configuration" {
  template = <<JSON
  "logConfiguration": {
    "logDriver": "awslogs",
    "options": {
      "awslogs-group": "${logs_group}",
      "awslogs-region": "${region}"
    }
  }
JSON

  vars {
    logs_group = "${vars.logs_group}"
    region = "${vars.region}"
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
        "${jsonencode("command")}: [${join(", ", data.template_file.command.*.rendered)}]",
        "${var.cpu != "" ? "${jsonencode("cpu")}: ${var.cpu}" : "" }",
        "${var.memory != "" ? "${jsonencode("memory")}: ${var.memory}" : "" }",
        "${jsonencode("image")}: ${jsonencode(var.image)}",
        "${length(var.links) > 0 ? "${jsonencode("links")}: ${jsonencode(var.links)}" : ""}",
        "${length(var.port_mappings) > 0 ?  join(",\n", data.template_file.port_mappings.*.rendered) : ""}",
        "${length(var.environment) > 0 ?  join(",\n", data.template_file.environment.*.rendered) : ""}",
        "${var.essential != "" ? data.template_file.essential.rendered : ""}"
      ))
    )}"
  }
}
