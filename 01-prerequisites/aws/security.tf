module "sg-ssh" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~>5.3.1"

  name    = "${var.deployment_id}-ssh"
  vpc_id  = module.vpc.vpc_id

  ingress_with_cidr_blocks = [
    {
      rule        = "ssh-tcp"
      cidr_blocks = "0.0.0.0/0"
    }
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