variable "region" {
  description = "aws region"
  type        = string
}

variable "deployment_id" {
  description = "deployment identifier"
  type        = string
}

variable "vpc_cidr" {
  description = "vpc cidr"
  type        = string
}

# enable peering between aws regions using transit gateway

variable "enable_tgw_peering" {
  description = "enable transit gateway peering"
  type        = bool
  default     = false
}