variable "region" {
    description = "AWS Region"
    default = "us-east-1"
}

variable "project_name" {
    description = "Name of the project"
    default = "fruits-webapp"
}

variable "github_repo_url" {
    description = "URL of the public GitHub repository"
    default = "https://github.com/omerbeithalahmy/fruits-webapp.git"
}

variable "instance_type" {
    description = "EC2 instance type"
    default = "t3.micro"
}

variable "vpc_cidr" {
  description = "VPC CIDR block"
  default     = "10.0.0.0/16"
}

variable "availability_zones" {
  description = "Availability Zones"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b"]
}
