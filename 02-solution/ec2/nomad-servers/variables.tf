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

variable "nomad_ent_license" {
  description = "nomad enterprise license"
  type        = string
}

variable "route53_sandbox_prefix" {
  description = "aws route53 sandbox account prefix"
  type        = string
}

variable "nomad_federation_peer_address" {
  description = "address of nomad server to federate with"
  type        = string
}