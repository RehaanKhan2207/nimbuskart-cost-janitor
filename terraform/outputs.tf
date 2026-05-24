output "vpc_id" {
  description = "The ID of the VPC from the network module"
  value       = module.network.vpc_id
}

output "public_subnet_ids" {
  description = "The IDs of the public subnets"
  value       = [module.network.public_subnet_a_id, module.network.public_subnet_b_id]
}

output "s3_bucket_name" {
  description = "The name of the log S3 bucket"
  value       = aws_s3_bucket.logs.id
}
