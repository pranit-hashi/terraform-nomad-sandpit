variable "deployment_id" {
  description = "deployment id"
  type        = string
}

variable "region" {
  description = "aws region"
  type        = string
}

variable "key_pair_private_key" {
  description = "private key of key pair"
  type        = string
}

variable "bastion_public_fqdn" {
  description = "Public fqdn of bastion node"
  type        =  string 
}