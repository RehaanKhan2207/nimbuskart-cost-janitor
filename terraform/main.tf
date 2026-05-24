# 1. Configure the Terraform settings and required providers
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# 2. Configure the AWS Provider to redirect everything to LocalStack
provider "aws" {
  region                      = var.aws_region
  access_key                  = "mock_key"
  secret_key                  = "mock_secret"
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true

  endpoints {
    ec2            = "http://localhost:4566"
    s3             = "http://localhost:4566"
    sts            = "http://localhost:4566"
    iam            = "http://localhost:4566"
  }
}

# 3. Call the Network Module and pass the required inputs
module "network" {
  source      = "./modules/network"
  environment = var.environment
  aws_region  = var.aws_region
}

# 4. Create a Security Group (Firewall)
resource "aws_security_group" "web" {
  name        = "${var.environment}-web-sg"
  description = "Allow web traffic and SSH"
  vpc_id      = module.network.vpc_id

  ingress {
    description = "HTTP from anywhere"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS from anywhere"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "SSH from configurable CIDR"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.ssh_allowed_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.environment}-web-sg"
    Project     = "NimbusKart"
    Environment = var.environment
    Owner       = "Engineering"
    ManagedBy   = "terraform"
  }
}

# 5. Create Two Web Server Instances
resource "aws_instance" "web_a" {
  ami           = "ami-df5db4b6" 
  instance_type = "t3.micro"
  subnet_id     = module.network.public_subnet_a_id
  vpc_security_group_ids = [aws_security_group.web.id]

  tags = {
    Name        = "${var.environment}-web-server-a"
    Project     = "NimbusKart"
    Environment = var.environment
    Owner       = "Engineering"
    ManagedBy   = "terraform"
    Tier        = "web"
  }
}

resource "aws_instance" "web_b" {
  ami           = "ami-df5db4b6"
  instance_type = "t3.micro"
  subnet_id     = module.network.public_subnet_b_id
  vpc_security_group_ids = [aws_security_group.web.id]

  tags = {
    Name        = "${var.environment}-web-server-b"
    Project     = "NimbusKart"
    Environment = var.environment
    Owner       = "Engineering"
    ManagedBy   = "terraform"
    Tier        = "web"
  }
}

# 6. Create an Unattached EBS Volume (Orphan Resource)
resource "aws_ebs_volume" "orphan_volume" {
  availability_zone = "${var.aws_region}a"
  size              = 10

  tags = {
    Name        = "${var.environment}-orphaned-disk"
    Project     = "NimbusKart"
    Environment = var.environment
    Owner       = "Engineering"
    ManagedBy   = "terraform"
  }
}

# 7. Create the S3 Bucket for Application Logs with Inline Rules
resource "aws_s3_bucket" "logs" {
  bucket = "${var.environment}-nimbuskart-logs-bucket"

  # Inline versioning block supported smoothly by local environments
  versioning {
    enabled = true
  }

  # Inline lifecycle block to prevent timing crashes
  lifecycle_rule {
    id      = "expire_old_versions"
    enabled = true

    noncurrent_version_expiration {
      days = 30
    }
  }

  tags = {
    Name        = "${var.environment}-logs"
    Project     = "NimbusKart"
    Environment = var.environment
    Owner       = "Engineering"
    ManagedBy   = "terraform"
  }
}
