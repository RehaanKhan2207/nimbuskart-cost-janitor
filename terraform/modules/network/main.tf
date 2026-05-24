# 1. Create the Main Network Container (VPC)
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true

  tags = {
    Name        = "${var.environment}-vpc"
    Project     = "NimbusKart"
    Environment = var.environment
    Owner       = "Engineering"
    ManagedBy   = "terraform"
  }
}

# 2. Create Public Subnet A
resource "aws_subnet" "public_a" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.20.1.0/24"
  availability_zone = "${var.aws_region}a"

  tags = {
    Name        = "${var.environment}-subnet-a"
    Project     = "NimbusKart"
    Environment = var.environment
    Owner       = "Engineering"
    ManagedBy   = "terraform"
  }
}

# 3. Create Public Subnet B
resource "aws_subnet" "public_b" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.20.2.0/24"
  availability_zone = "${var.aws_region}b"

  tags = {
    Name        = "${var.environment}-subnet-b"
    Project     = "NimbusKart"
    Environment = var.environment
    Owner       = "Engineering"
    ManagedBy   = "terraform"
  }
}
