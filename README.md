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

#### Optional

- `command` - _(List)_ The command that is passed to the container.
- `entry_point` - _(List)_ The command that is passed to the container.
- `essential` - _(Boolean)_ Whether the task is essential. Default is `true`.
- `links` - _(List)_ A list of other containers to link this task to. Allows containers to communicate with each other without the need for port mappings. 
- `cpu` - _(Integer)_ The number of CPU units to reserve for the task container.
- `memory` - _(Integer)_ The hard limit (in MiB) of memory to present to the container.
- `port_mappings` - _(List)_ A list of port mappings. Each entry should be a map that defines `container_port` as well as optionally definining `protocol` (defaults to `tcp`) and `host_port`.
- `environment` - _(List)_ A list of environment variables. Each entry must be a map that defines `name` and `value`.
- `logs_group` - _(String)_ The CloudWatch Logs group to send logs to.
- `logs_prefix` - _(String)_ The stream prefix to use in CloudWatch Logs.
- `region` - _(String)_ The region for CloudWatch Logs.

Usage
-----

#### A Single Task Definition

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

  # Remember that the module just exports a hash, but this argument requires a JSON list.
  container_definitions = "[${module.ecs_task_definition.container_definition}]"
}
```

#### Multiple Task Definitions

```hcl
module "my_task_definition" {
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

module "some_other_task_definition" {
  source  = "github.com/joestump/tf_aws_ecs_container_definition"
  name    = "some-other-task"
  image   = "quay.io/carmera/some-other-task:latest"
  command = ["/usr/bin", "ruby", "--help"]
  environment = [
    {
      name = MY_TASK_API_KEY
      value = "${vars.my_task_api_key}"
    }
  ]
}

resource "aws_ecs_task_definition" "service" {
  family                = "my-task"

  # We need to use a bit of TF interpolation to pass multiple container definitions.
  container_definitions = "[${join(",\n", list(module.my_task_definition.container_definition, module.some_other_task_definition.container_definition))}]"
}
```

Outputs
=======

- `container_definition` - _(String)_ JSON string of the container definition. **NOTE:** This module outputs the JSON hash of the definition, while the `container_definitions` argument expects a JSON list. See the usage section above for more.

Authors
=======

* [Aurynn Shaw](https://github.com/aurynn)
* [Joe Stump](https://github.com/joestump)

License
=======

[BSD](LICENSE)
