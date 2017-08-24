ECS Task Definition Module
==========================

A terraform module to create `container_definition` JSON blobs that can be passed directly to [`aws_ecs_task_definition`](https://www.terraform.io/docs/providers/aws/r/ecs_task_definition.html). This module is a direct descendent of the TF code outlined by Aurynn Shaw [in this blog post](http://blog.aurynn.com/2017/2/26-more-fun-with-terraform-templates).

This module currently supports Terraform 0.10.x, but does not require it.

Module Input Variables
----------------------

**NOTE:** Not all [container definition parameters](http://docs.aws.amazon.com/AmazonECS/latest/developerguide/task_definition_parameters.html#standard_container_definition_params) are currently support. 

#### Required

- `name` - _(String)_ ECS task name.
- `image` - _(String)_ The Docker container image to use.
- `command` - _(String)_ The command that is passed to the container.

#### Optional

- `essential` - _(Boolean)_ Whether the task is essential. Default is `true`.
- `links` - _(List)_ A list of other containers to link this task to. Allows containers to communicate with each other without the need for port mappings. 
- `cpu` - _(Integer)_ The number of CPU units to reserve for the task container.
- `memory` - _(Integer)_ The hard limit (in MiB) of memory to present to the container.
- `port_mappings` - _(List)_ A list of port mappings. Each entry should be a map that defines `container_port` as well as optionally definining `protocol` (defaults to `tcp`) and `host_port`.

Usage
-----

```hcl
module "ecs_task_definition" {
  source  = "github.com/joestump/tf_aws_ecs_container_definition"
  name    = "my-task"
  image   = "quay.io/carmera/my-task:latest"
  command = ["/usr/bin", "python", "--help"]
  environment = [
    {
      name = MY_API_KEY
      value = "${vars.MY_API_KEY}"
    },
    {
      name = AWS_DEFAULT_REGION
      value = "${vars.region}"
    }
  ]
}

resource "aws_ecs_task_definition" "service" {
  family                = "my-task"
  container_definitions = "${module.ecs_task_definition.container_definition}"
}
```

Outputs
=======

- `container_definition` - _(String)_ JSON string of the container definition.

Authors
=======

* [Aurynn Shaw](https://github.com/aurynn)
* [Joe Stump](https://github.com/joestump)

License
=======

[BSD](LICENSE)
