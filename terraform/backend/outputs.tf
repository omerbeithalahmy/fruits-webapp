output "s3_bucket_id" {
  description = "ID of the s3 bucket for terraform state"
  value       = aws_s3_bucket.terraform_state.id
}

output "dynamodb_table_id" {
  description = "ID of the dynamodb table for state locking"
  value       = aws_dynamodb_table.terraform_locks.id
}

output "backend_config" {
  description = "Backend configuration to use in environment files"
  value       = <<-EOT
      terraform {
        backend "s3" {
          bucket = "${aws_s3_bucket.terraform_state.id}"
          region = "${var.region}"
          dynamodb_table = "${aws_dynamodb_table.terraform_locks.id}"
          key = "state/terraform.tfstate"
          encrypt = true
          }
        }
    EOT
}