data "aws_subnets" "public" {
  filter {
    name   = "tag:Name"
    values = ["*public*"]
  }
}

resource "aws_lb_target_group" "nomad-servers" {
  name     = "${var.deployment_id}-servers"
  port     = 4646
  protocol = "TCP"
  vpc_id   = data.aws_vpc.this.id
}

resource "aws_lb_target_group_attachment" "nomad-servers" {
  target_group_arn = aws_lb_target_group.nomad-servers.arn
  target_id        = aws_instance.nomad-server.id
}

resource "aws_lb" "nomad-http-api" {
  name               = "${var.deployment_id}-http-api"
  internal           = false
  load_balancer_type = "network"
  security_groups    = [module.sg-nomad-server-http-api-lb.security_group_id]
  subnets            = data.aws_subnets.public.ids
}

resource "aws_lb_listener" "nomad-http-api" {
  load_balancer_arn = aws_lb.nomad-http-api.arn
  port              = "4646"
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.nomad-servers.arn
  }
}
