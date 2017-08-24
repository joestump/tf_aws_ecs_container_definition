ECS Task Definition Module
==========================

A terraform module to create `container_definition` JSON blobs that can be passed directly to [`aws_ecs_task_definition`](https://www.terraform.io/docs/providers/aws/r/ecs_task_definition.html). This module is a direct descendent of the TF code outlined by Aurynn Shaw [in this blog post](http://blog.aurynn.com/2017/2/26-more-fun-with-terraform-templates).

This module currently supports Terraform 0.10.x, but does not require it.

Module Input Variables
----------------------

#### Required

- `name` - ECS task name.
- `image` - The Docker container image to use.
- `command` - The command that is passed to the container.

#### Optional

- `essential` - _(Boolean)_ Whether the task is essential. Default is `true`.

Usage
-----

```hcl
module "ecs-cluster" {
  source    = "github.com/terraform-community-modules/tf_aws_ecs"
  name      = "infra-services"
  servers   = 1
  subnet_id = ["subnet-6e101446"]
  vpc_id    = "vpc-99e73dfc"
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
