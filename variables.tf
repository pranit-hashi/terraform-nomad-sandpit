# generic variables

variable "deployment_name" {
  description = "deployment name to prefix resources"
  type        = string
  default     = "sandpit"
}

# enable & disable modules

variable "deploy_platform_k8s_eks" {
  description = "deploy k8s aws eks"
  type        = bool
  default     = false
}

variable "deploy_solution_k8s_vault" {
  description = "deploy k8s vault"
  type        = bool
  default     = false
}

# amazon web services (aws) variables

variable "aws_region_1" {
  description = "aws sydney region"
  type        = string
  default     = "ap-southeast-2"
}

variable "aws_region_2" {
  description = "aws singapore region"
  type        = string
  default     = "ap-southeast-1"
}

variable "aws_route53_sandbox_prefix" {
  description = "aws route53 sandbox account prefix"
  type        = string
  default     = "pranit-raje"
}

# hashicorp enterprise server variables

variable "nomad_ent_license" {
  description = "nomad enterprise license"
  type        = string
  default     = ""
}