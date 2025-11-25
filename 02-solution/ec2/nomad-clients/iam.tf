resource "aws_iam_role" "nomad-join" {
  name               = "${var.deployment_id}-nomad-join"
  assume_role_policy = "${file("${path.module}/policies/assume-role.json")}"
}

resource "aws_iam_policy" "nomad-join" {
  name        = "${var.deployment_id}-nomad-join"
  description = "allows nomad client to describe instances for joining"
  policy      = "${file("${path.module}/policies/describe-instances.json")}"
}

resource "aws_iam_policy_attachment" "nomad-join" {
  name       = "${var.deployment_id}-nomad-join"
  roles      = ["${aws_iam_role.nomad-join.name}"]
  policy_arn = "${aws_iam_policy.nomad-join.arn}"
}

resource "aws_iam_instance_profile" "nomad-join" {
  name  = "${var.deployment_id}-nomad-join"
  role  = aws_iam_role.nomad-join.name
}