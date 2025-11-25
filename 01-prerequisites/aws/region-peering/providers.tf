terraform {
  required_providers {
    aws = {
      configuration_aliases = [ aws.syd, aws.sgp ]
    }
  }
}