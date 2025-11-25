packer {
  required_version = ">= 1.14.3"
}

variable "aws_region" {
  type    = string
  default = "ap-southeast-1"
}

variable "nomad_version" {
  type    = string
  default = "1.11.0+ent"
}

variable "nomad_download_url" {
  type    = string
  default = "${env("NOMAD_DOWNLOAD_URL")}"
}

data "amazon-ami" "ubuntu20" {
  filters = {
    architecture                       = "x86_64"
    "block-device-mapping.volume-type" = "gp2"
    name                               = "ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"
    root-device-type                   = "ebs"
    virtualization-type                = "hvm"
  }
  most_recent = true
  owners      = ["099720109477"]
  region      = "${var.aws_region}"
}

source "amazon-ebs" "ubuntu20-ami" {
  ami_description             = "An Ubuntu 20.04 AMI that has Nomad installed."
  ami_name                    = "nomad-ubuntu-${formatdate("YYYYMMDDhhmm", timestamp())}"
  associate_public_ip_address = true
  instance_type               = "t2.micro"
  region                      = "${var.aws_region}"
  source_ami                  = "${data.amazon-ami.ubuntu20.id}"
  ssh_username                = "ubuntu"
  tags = {
    application     = "nomad"
    nomad_version  = "${var.nomad_version}"
    owner           = "tphan@hashicorp.com"
    packer_source   = "https://github.com/phan-t/terraform-nomad-sandpit/blob/master/examples/amis/nomad-enterprise/nomad-ent.pkr.hcl"
  }
}

build {
  sources = ["source.amazon-ebs.ubuntu20-ami"]

  provisioner "shell" {
    inline = ["mkdir -p /tmp/terraform-nomad-sandpit/"]
  }

  provisioner "shell" {
    inline       = ["git clone https://github.com/phan-t/terraform-nomad-sandpit.git /tmp/terraform-nomad-sandpit"]
    pause_before = "30s"
  }

  provisioner "shell" {
    inline       = ["if test -n \"${var.nomad_download_url}\"; then", "/tmp/terraform-nomad-sandpit/examples/amis/nomad/scripts/install-nomad --download-url ${var.nomad_download_url};", "else", "/tmp/terraform-nomad-sandpit/examples/amis/nomad/scripts/install-nomad --version ${var.nomad_version};", "fi"]
    pause_before = "30s"
  }
  
#   provisioner "shell" {
#     inline       = ["/tmp/terraform-nomad-sandpit/examples/amis/nomad/scripts/setup-systemd-resolved"]
#     pause_before = "30s"
#   }
}