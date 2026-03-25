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
