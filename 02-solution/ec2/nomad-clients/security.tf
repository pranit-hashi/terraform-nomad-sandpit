data "aws_vpc" "this" {
  filter {
    name   = "tag:Name"
    values = ["${var.deployment_id}"]
  }
}

data "aws_security_group" "sg-ssh" {
  filter {
    name   = "tag:Name"
    values = ["${var.deployment_id}-ssh"]
  }
}


module "sg-nomad-client" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~>5.3.1"

  name    = "${var.deployment_id}-nomad-client"
  vpc_id  = data.aws_vpc.this.id

  ingress_with_cidr_blocks = [
    {
      from_port   = 4646
      to_port     = 4646
      protocol    = "tcp"
      description = "http-api-tcp"
      cidr_blocks = "0.0.0.0/0"
    },
    {
      from_port   = 4647
      to_port     = 4647
      protocol    = "tcp"
      description = "rpc-tcp"
      cidr_blocks = "0.0.0.0/0"
    },
    {
      from_port   = 4648
      to_port     = 4648
      protocol    = "tcp"
      description = "self-wan-tcp"
      cidr_blocks = "0.0.0.0/0"
    },
  ]
  egress_with_cidr_blocks = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      description = "any-any"
      cidr_blocks = "0.0.0.0/0"
    }
  ]
}